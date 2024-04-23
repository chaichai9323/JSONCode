// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(peer)
public macro JSONCodeKey(_ key: String ...) = #externalMacro(module: "JSONCodeMacros", type: "JSONCodeKeyMacro")

@attached(member, names: arbitrary)
@attached(extension, conformances: Codable)
public macro JSONCode() = #externalMacro(module: "JSONCodeMacros", type: "JSONCodeMacro")

@attached(member, names: arbitrary)
public macro JSONCodeSub() = #externalMacro(module: "JSONCodeMacros", type: "JSONCodeSubMacro")

@attached(peer)
public macro JSONCodeMapper<I: Codable, O: Any>(_ key: I.Type, _ from: (I) -> O, _ to: (O) -> I) = #externalMacro(module: "JSONCodeMacros", type: "JSONCodeMapperMacro")
