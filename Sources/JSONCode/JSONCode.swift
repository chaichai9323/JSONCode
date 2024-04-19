// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "JSONCodeMacros", type: "StringifyMacro")

@attached(peer)
public macro JSONCodeKey(_ key: String ...) = #externalMacro(module: "JSONCodeMacros", type: "JSONCodeKeyMacro")

@attached(member, names: arbitrary)
@attached(extension, conformances: Codable)
public macro JSONCode() = #externalMacro(module: "JSONCodeMacros", type: "JSONCodeMacro")

@attached(member, names: arbitrary)
public macro JSONCodeSub() = #externalMacro(module: "JSONCodeMacros", type: "JSONCodeSubMacro")
