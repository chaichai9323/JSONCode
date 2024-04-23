//
//  File.swift
//  
//
//  Created by chai chai on 2024/4/18.
//

import Foundation

public struct JSONCodeKey: CodingKey {
    public var stringValue: String
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public var intValue: Int?
    
    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    fileprivate init(_ key: String) {
        self.stringValue = key
        self.intValue = nil
    }
}

public extension KeyedDecodingContainer where K == JSONCodeKey {
    func decode<T: Decodable>(_ type: T.Type, jsonKeys keys: [String]) throws -> T {
        
        for k in keys {
            if let res = try? decode(type, forKey: JSONCodeKey(k)) {
                return res
            }
        }
        
        throw NSError(domain: "没有找到key: \(keys.joined(separator: ","))", code: 0)
    }
    
    func decode<T: Decodable, R: Any>(
        _ type: T.Type,
        jsonKeys keys: [String],
        transform: (T) -> R
    ) throws -> R {
        
        for k in keys {
            if let res = try? decode(type, forKey: JSONCodeKey(k)) {
               return transform(res)
            }
        }
        
        throw NSError(domain: "没有找到key: \(keys.joined(separator: ","))", code: 0)
    }
    
}

public extension KeyedEncodingContainer where K == JSONCodeKey {
    mutating func encode<T: Encodable>(_ value: T?, jsonKeys keys: [String]) throws {
        guard let key = keys.first else {
            throw NSError(domain: "没有指定key: \(keys.joined(separator: ","))", code: 0)
        }
        
        try encodeIfPresent(value, forKey: JSONCodeKey(key))
    }
    
    mutating func encode<T: Any, R: Encodable>(
        _ value: T?,
        jsonKeys keys: [String],
        transform: (T) -> R
    ) throws {
        guard let key = keys.first else {
            throw NSError(domain: "没有指定key: \(keys.joined(separator: ","))", code: 0)
        }
        
        guard let v = value else {
            try encodeNil(forKey: JSONCodeKey(key))
            return
        }
        
        try encodeIfPresent(transform(v), forKey: JSONCodeKey(key))
    }
}
