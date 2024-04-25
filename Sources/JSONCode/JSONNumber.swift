//
//  File.swift
//  
//
//  Created by chai chai on 2024/4/25.
//

import Foundation

struct JSONNumber<T: Decodable>: Decodable {
    
    let valueType: T.Type
    
    var value: T
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        self.valueType = T.self
        
        if let v = try? container.decode(valueType) {
            value = v
            return
        }
        
        if valueType == Bool.self || valueType == Bool?.self{
            let res: Bool
            if let v = try? container.decode(Bool.self) {
                res = v
            } else if let v = try? container.decode(Int.self) {
                res = v != 0
            } else if let v = try? container.decode(Double.self) {
                res = !v.isZero
            } else if let v = try? container.decode(String.self) {
                let str = v.trimmingCharacters(in: .whitespacesAndNewlines)
                res = str == "true"
            } else {
                throw NSError(domain: "无法转换成\(String(describing: valueType)), key: \(container.codingPath.map{$0.stringValue}.joined(separator: "."))", code: 0)
            }
            value = res as! T
            return
        }
        
        if valueType == Int.self || valueType == Int?.self {
            let res: Int
            if let v = try? container.decode(Bool.self) {
                res = v ? 1 : 0
            } else if let v = try? container.decode(Int.self) {
                res = v
            } else if let v = try? container.decode(Double.self) {
                res = Int(v)
            } else if let v = try? container.decode(String.self) {
                res = Int(v) ?? 0
            } else {
                throw NSError(domain: "无法转换成\(String(describing: valueType)), key: \(container.codingPath.map{$0.stringValue}.joined(separator: "."))", code: 0)
            }
            value = res as! T
            return
        }
        
        if valueType == Double.self || valueType == Double?.self || valueType == Float.self || valueType == Float?.self {
            let res: Double
            if let v = try? container.decode(Bool.self) {
                res = v ? 1.0 : 0.0
            } else if let v = try? container.decode(Int.self) {
                res = Double(v)
            } else if let v = try? container.decode(Double.self) {
                res = v
            } else if let v = try? container.decode(String.self) {
                res = Double(v) ?? 0.0
            } else {
                throw NSError(domain: "无法转换成\(String(describing: valueType)), key: \(container.codingPath.map{$0.stringValue}.joined(separator: "."))", code: 0)
            }
            
            if valueType == Float.self || valueType == Float?.self {
                value = Float(res) as! T
            } else {
                value = res as! T
            }
            return
        }
        
        if valueType == String.self || valueType == String?.self {
            let res: String
            if let v = try? container.decode(Bool.self) {
                res = "\(v)"
            } else if let v = try? container.decode(Int.self) {
                res = "\(v)"
            } else if let v = try? container.decode(Double.self) {
                res = "\(v)"
            } else if let v = try? container.decode(String.self) {
                res = v
            } else {
                throw NSError(domain: "无法转换成\(String(describing: valueType)), key: \(container.codingPath.map{$0.stringValue}.joined(separator: "."))", code: 0)
            }
            value = res as! T
            return
        }
        
        throw NSError(domain: "没有内置的类型转换\(String(describing: valueType))", code: 0)
    }
}
