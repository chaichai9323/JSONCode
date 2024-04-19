//
//  File.swift
//  
//
//  Created by chai chai on 2024/4/17.
//

import Foundation
import SwiftSyntax

struct MemberManager {
    
    struct PropertyComponent {
        let name: String
        let type: String
        let isOpt: Bool
        let value: String?
        private let keys: [String]
        
        var jsonKeys: String {
            let str = (keys + ["\"\(name)\""]).joined(separator: ", ")
            return "[\(str)]"
        }
        
        init(name: String, type: String, isOpt: Bool, value: String?, keys: [String]) {
            self.name = name
            self.type = type
            self.isOpt = isOpt
            self.value = value
            self.keys = keys
        }
    }
    
    private let declaration: DeclGroupSyntax
    private let isSubClass: Bool
    
    private var propertyList: [PropertyComponent] = []
    
    init(_ declare: DeclGroupSyntax, isSubClass: Bool = false) {
        self.declaration = declare
        self.isSubClass = isSubClass
        loadPropertyList()
    }
    
    private var prefix: String {
        return declaration.is(ClassDeclSyntax.self) ? "required " : ""
    }
    
    private var decodeBody: String {
        return propertyList.map { property in
            let cmd = """
container.decode(Swift.type(of: self.\(property.name)), jsonKeys: \(property.jsonKeys))
"""
            let res: String
            if let dv = property.value {
                res = "self.\(property.name) = (try? \(cmd)) ?? \(dv)"
            } else {
                res = "self.\(property.name) = try \(cmd)"
            }
            return res
        }.joined(separator: "\n")
    }
    
    var decoder: String {
        let subStr = isSubClass ? "\ntry super.init(from: decoder)" : ""
        return """
        \(prefix)public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: JSONCodeKey.self)
            \(decodeBody)\(subStr)
        }
        """
    }
    
    private var encodeBody: String {
        return propertyList.map { property in
            return """
            try container.encode(self.\(property.name), jsonKeys: \(property.jsonKeys))
            """
        }.joined(separator: "\n")
    }
    
    var encoder: String {
        let subStr = isSubClass ? "try super.encode(to: encoder)\n" : ""
        return """
        \(isSubClass ? "override " : "")public func encode(to encoder: any Encoder) throws {
            \(subStr)var container = encoder.container(keyedBy: JSONCodeKey.self)
            \(encodeBody)
        }
        """
    }
    
    var syntax: [DeclSyntax] {
        return [decoder, encoder].map { DeclSyntax("\(raw: $0)") }
    }
    
    private mutating func loadPropertyList() {
        self.propertyList = declaration.memberBlock.members.compactMap { member -> VariableDeclSyntax? in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  variable.isStorageVar else {
                return nil
            }
            return variable
        }.flatMap { v -> [PropertyComponent] in
            let keys = v.jsonKeys
            return v.bindings.compactMap { b -> PropertyComponent? in
                guard let name = b.varName,
                      let type = b.getVarType() else {
                    return nil
                }
                return .init(
                    name: name,
                    type: type.type,
                    isOpt: type.isOption,
                    value: b.initValue,
                    keys: keys
                )
            }
        }
    }
}

//MARK: - 自定义 key
extension VariableDeclSyntax {
    var jsonKeys: [String] {
        let key = attributes.compactMap{ $0.as(AttributeSyntax.self) }
            .first { att in
                guard let name = att.attributeName.as(IdentifierTypeSyntax.self) else {
                    return false
                }
                switch name.name.tokenKind {
                    case .identifier(let k): return k == "JSONCodeKey"
                    default: return false
                }
            }?
            .arguments?
            .as(LabeledExprListSyntax.self)?
            .compactMap{ $0.expression.as(StringLiteralExprSyntax.self)?.description }
        guard let attKeys = key else {
            return []
        }
        return attKeys
    }
}

//MARK: - 判断属性是存储属性
extension VariableDeclSyntax {
    
    ///是否是存储变量
    var isStorageVar: Bool {
        let isStatic = modifiers.contains { md in
            let kind = md.name.tokenKind
            switch kind {
                case .keyword(let k): return k == .static
                default: return false
            }
        }
        
        ///静态属性
        if isStatic {
            return false
        }
       
        guard let bindings = bindings.last else {
            return false
        }
        
        guard let acce = bindings.accessorBlock?.accessors else {
            return true
        }
        
        switch acce {
            case .accessors(let list):
                return list.filter{ acce in
                    switch acce.accessorSpecifier.tokenKind {
                        case .keyword(let k):
                            if k == .set || k == .get {
                                return true
                            } else {
                                return false
                            }
                        default:
                            return false
                    }
                }.isEmpty
            case .getter:
                return false
        }
    }
}

//MARK: - 获取变量 名字 类型 初始值
extension PatternBindingSyntax {
    
    /// 变量名字
    var varName: String? {
        guard let res = pattern.as(IdentifierPatternSyntax.self)?.identifier.tokenKind else {
            return nil
        }
        switch res {
            case .identifier(let s):
                return s
            default:
                return nil
        }
    }
    
    /// 初始化的值
    var initValue: String? {
        guard let res = initializer else { return nil }
        return res.value.description
    }
    
    /// 变量类型
    func getVarType() -> (type: String, isOption: Bool)? {
        var type: String? = nil
        var isOption: Bool = false
        
        if let varType = typeAnnotation?.type {
            var kind: IdentifierTypeSyntax?
            if let typeSyn = varType.as(OptionalTypeSyntax.self) {
                kind = typeSyn.wrappedType.as(IdentifierTypeSyntax.self)
                isOption = true
            } else {
                kind = varType.as(IdentifierTypeSyntax.self)
            }
            if let token = kind?.name {
                switch token.tokenKind {
                    case .identifier(let t):
                        type = t
                    default:
                        type = nil
                }
            }
        } else if let value = initializer?.value {
            if value.is(StringLiteralExprSyntax.self) {
                type = "String"
            } else if value.is(IntegerLiteralExprSyntax.self) {
                type = "Int"
            } else if value.is(BooleanLiteralExprSyntax.self) {
                type = "Bool"
            } else if value.is(FloatLiteralExprSyntax.self) {
                type = "Double"
            } else if let fuc = value.as(FunctionCallExprSyntax.self),
                      let expr = fuc.calledExpression.as(DeclReferenceExprSyntax.self) {
                switch expr.baseName.tokenKind {
                    case .identifier(let s):
                        if s == "Optional" {
                            isOption = true
                            guard let lab = fuc.arguments.first else {
                                break
                            }
                            if lab.expression.is(StringLiteralExprSyntax.self) {
                                type = "String"
                            } else if lab.expression.is(IntegerLiteralExprSyntax.self) {
                                type = "Int"
                            } else if lab.expression.is(BooleanLiteralExprSyntax.self) {
                                type = "Bool"
                            } else if lab.expression.is(FloatLiteralExprSyntax.self) {
                                type = "Double"
                            } else if let optFunc = lab.expression.as(FunctionCallExprSyntax.self),
                                      let optExpr = optFunc.calledExpression.as(DeclReferenceExprSyntax.self) {
                                switch optExpr.baseName.tokenKind {
                                    case .identifier(let s):
                                        type = s
                                    default:
                                        type = nil
                                }
                            }
                        } else {
                            type = s
                        }
                    default:
                        type = nil
                }
            }
        }
        
        if let type {
            return (type, isOption)
        } else {
            return nil
        }
    }
}

extension DeclGroupSyntax {
    
    var jsonSub: MemberManager {
        return MemberManager(self,isSubClass: true)
    }
    
    var json: MemberManager {
        return MemberManager(self)
    }
}
