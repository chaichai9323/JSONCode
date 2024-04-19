import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(JSONCode)
import JSONCode
#endif

#if canImport(JSONCodeMacros)
import JSONCodeMacros
#endif

final class JSONCodeTests: XCTestCase {
    
    func testJSONCodeMacro() {
#if canImport(JSONCodeMacros)
        assertMacroExpansion(
    """
    @JSONCode
    struct Person {
        @JSONCodeKey("mingzi", "mz")
        var name: String = "default"
    }
    """,
    expandedSource:
    """
    struct Person {
        @JSONCodeKey("mingzi", "mz")
        var name: String = "default"
    
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: JSONCodeKey.self)
            self.name = (try? container.decode(Swift.type(of: self.name), jsonKeys: ["mingzi", "mz", "name"])) ?? "default"
        }
    
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: JSONCodeKey.self)
            try container.encode(self.name, jsonKeys: ["mingzi", "mz", "name"])
        }
    }
    
    extension Person: Codable {
    }
    """,
    macros:[
        "JSONCode": JSONCodeMacro.self
    ])
#endif
    }
    
    func testMacro() {
#if canImport(JSONCodeMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: [
                "stringify": StringifyMacro.self
            ]
        )
#endif
    }
}
