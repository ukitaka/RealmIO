//
//  RealmOperationSpec.swift
//  RealmIO
//
//  Created by ukitaka on 2017/05/30.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift
import RealmIO
import XCTest
import Quick
import Nimble

class RealmOperationSpec: QuickSpec {
    let realm = try! Realm(configuration: Realm.Configuration(fileURL: nil, inMemoryIdentifier: "for test"))

    override func spec() {
        super.spec()

        describe("`add` operator") {
            beforeEach {
                try! self.realm.write {
                    self.realm.deleteAll()
                }
            }

            it ("works well") {
                let dog = Dog()
                dog.name = "Taro"
                dog.age = 4
                let addTaro = Realm.IO.add(dog)
                try! self.realm.run(io: addTaro)
                let readTaro = RealmRead<Dog>.object(forPrimaryKey: "Taro")
                let result = try! self.realm.run(io: readTaro)
                expect(result?.name).to(equal("Taro"))
                expect(result?.age).to(equal(4))
            }
        }

        describe("`delete` operator") {
            beforeEach {
                try! self.realm.write {
                    self.realm.deleteAll()
                    self.realm.add(Dog.dogs)
                }
            }

            it ("works well") {
                let delete = RealmRead<Dog>.object(forPrimaryKey: "A").flatMap { dog in Realm.IO.delete(dog!) }
                try! self.realm.run(io: delete)
                let readAll = Realm.IO.objects(Dog.self)
                let result = try! self.realm.run(io: readAll)
                expect(result.count).to(equal(3))
            }
        }
    }
}
