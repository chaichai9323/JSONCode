import JSONCode
import Foundation

@JSONCode
class Person {
    @JSONCodeKey("mingzi", "mz")
    var name: String = "默认名字"
    
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

do {
    let p = try JSONDecoder().decode(Student.self, from: js.data(using: .utf8)!)
    print(p.desc)
} catch {
    print(error.localizedDescription)
}
