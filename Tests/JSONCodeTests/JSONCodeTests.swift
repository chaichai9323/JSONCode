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

enum GEN {
    case F
    case M
    
    var desc: String {
        "性别: \(self == .F ? "女" : "男")"
    }
}

@JSONCode
class Person {
    @JSONCodeKey("mingzi", "mz")
    var name: String = "默认名字"
    
    @JSONCodeMapper(String.self, { s -> GEN in
        if s.lowercased().prefix(1) == "f" {
            return .F
        } else {
            return .M
        }
    }, { s -> String in
        switch s {
            case .F: return "Female"
            case .M: return "Male"
        }
    })
    var gender: GEN = .F
    
    var desc: String {
        "名字:\(name)"
    }
}

@JSONCodeSub
class Student: Person {
    @JSONCodeKey("nj")
    var grade: String = "默认年级"
    @JSONCodeKey("bj")
    var clbum: Int = 1
    
    override var desc: String {
        "学生名字:\(name) \(gender.desc), 年级:\(grade), 班级:\(clbum)"
    }
}


@JSONCode
class Resp<T: Codable>: NSObject, Codable {
    var code: Int?
    var msg: String?
    var data: T?
}

let rjs = """
{
    "code": 200,
    "msg": "success",
    "data": true
}
"""

final class JSONCodeTests: XCTestCase {
    
    func testJsonModel() throws {
        let js = """
        {
            "mingzi": "Terry",
            "gender": "m",
            "nj": "3年级",
            "bj": 1
        }
        """
        
        let p = try JSONDecoder().decode(Student.self, from: js.data(using: .utf8)!)
        XCTAssertEqual(p.name, "Terry")
        XCTAssertEqual(p.gender, .M)
        
        
        do {
            let m = try JSONDecoder().decode(Resp<Int>.self, from: rjs.data(using: .utf8)!)
            if m.code == 200 {
                print(m.data!)
            }
        } catch {
            print(error.localizedDescription)
        }
//        let dat = try JSONEncoder().encode(p)
//        print(String(data: dat, encoding: .utf8)!)
        
    }
    
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
}
