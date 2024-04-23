# JSONCode

## Installation

#### Cocoapods

```
pod 'JSONCodeSwiftMacro'
```

#####

If third-party libraries have dependencies on JSONCodeSwiftMacro, You need to configure 'spec' file
```
s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => "-load-plugin-executable $(PODS_ROOT)/JSONCodeSwiftMacro/Macro/release/JSONCodeMacros#JSONCodeMacros"
}
  
s.dependency 'JSONCodeSwiftMacro'
```

#### Swift Package Manager

```
https://github.com/chaichai9323/JSONCode.git
```

# Example

```swift

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
        "学生名字:\(name), 年级:\(grade), 班级:\(clbum)"
    }
}

let js = """
{
    "mingzi": "Terry",
    "nj": "3年级",
    "bj": 1
}
"""

let js2 = """
    {
        "name": "Terry",
        "grade": "3年级",
        "bj": 1
    }
"""

if let p = try? JSONDecoder().decode(Student.self, from: js.data(using: .utf8)!){
    print(p.desc)//学生名字:Terry, 年级:3年级, 班级:1
}
        
if let p = try? JSONDecoder().decode(Student.self, from: js2.data(using: .utf8)!) {
    print(p.desc)//学生名字:Terry, 年级:3年级, 班级:1
}

```
