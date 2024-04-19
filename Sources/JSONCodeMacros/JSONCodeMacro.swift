import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

//MARK: - JSON Key 自定义
public struct JSONCodeKeyMacro: PeerMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        let s = declaration.description
        if s.count > 0 {
            return []
        }
        return []
    }
    
}

//MARK: - JSON 模型
public struct JSONCodeMacro: ExtensionMacro, MemberMacro {
    
    ///添加Codable协议
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        if let types = declaration.inheritanceClause?.inheritedTypes,
           types.contains(where: { $0.type.description.contains("Codable") }) {
            return []
        }
        
        let dec = DeclSyntax("extension \(type.trimmed): Codable {}")
        guard let res = dec.as(ExtensionDeclSyntax.self) else {
            return []
        }
        return [res]
    }
    
    ///添加 init(from decoder: any Decoder) & encode(to encoder: any Encoder) 方法
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return declaration.json.syntax
    }
}

//MARK: - JSON 子类集成模型
public struct JSONCodeSubMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return declaration.jsonSub.syntax
    }
}

//MARK: - 导出宏
@main
struct JSONCodePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        JSONCodeKeyMacro.self,
        JSONCodeMacro.self,
        JSONCodeSubMacro.self
    ]
}
