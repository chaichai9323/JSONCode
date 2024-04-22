//
//  ViewController.swift
//  JSONCode
//
//  Created by chaichai9323 on 04/19/2024.
//  Copyright (c) 2024 chaichai9323. All rights reserved.
//

import UIKit
import JSONCodeSwiftMacro
import OtherLib

@JSONCode
struct Info {
    var phone = "默认电话号码"
    @JSONCodeKey("address")
    var addr: String?
}

@JSONCode
struct Person: Codable {
    @JSONCodeKey("mz")
    var name: String?
    
    var info: Info?
}

class ViewController: UIViewController {

    let js = """
{
    "name": "chaichai",
    "animation": "pop",
    "info": {
        "phone": "138 xxxx xxxx",
        "address": "chengdu"
    }
}
"""
    
    @IBOutlet var msgLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard var p = try? JSONDecoder().decode(Person.self, from: js.data(using: .utf8)!) else {
            msgLab.text = "json不能解码"
            return
        }
        if p.name == nil {
            p.name = "空值"
        }
        guard let data = try? JSONEncoder().encode(p),
              let str = String(data: data, encoding: .utf8) else {
            return
        }
        
        msgLab.text = str
        
        testOther()
    }

    func testOther() {
        
        if let p = try? JSONDecoder().decode(OtherLibProperty.self, from: js.data(using: .utf8)!) {
            print(p.name ?? "空名字")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

