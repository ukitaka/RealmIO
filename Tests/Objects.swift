//
//  Objects.swift
//  RealmTxn
//
//  Created by Yuki Takahashi on 2017/04/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import Foundation
import RealmSwift
import RealmTxn

class Dog: Object {
    dynamic var name: String = ""
    dynamic var age: Int = 0

    override class func primaryKey() -> String? {
        return "name"
    }
}

extension Dog {
    static var dogA: Dog {
        let dog = Dog()
        dog.age = 10
        dog.name = "A"
        return dog
    }

    static var dogB: Dog {
        let dog = Dog()
        dog.age = 11
        dog.name = "B"
        return dog
    }

    static var dogC: Dog {
        let dog = Dog()
        dog.age = 12
        dog.name = "C"
        return dog
    }

    static var dogD: Dog {
        let dog = Dog()
        dog.age = 13
        dog.name = "D"
        return dog
    }

    static var dogs: [Dog] {
        return [dogA, dogB, dogC, dogD]
    }
}
