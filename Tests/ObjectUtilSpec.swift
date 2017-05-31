//
//  ObjectUtilSpec.swift
//  RealmIO
//
//  Created by ukitaka on 2017/05/30.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift
@testable import RealmIO
import XCTest
import Quick
import Nimble

class ObjectUtilSpec: QuickSpec {
    let realm = try! Realm(configuration: Realm.Configuration(fileURL: nil, inMemoryIdentifier: "for test"))

    override func spec() {
        super.spec()

        beforeEach {
            try! self.realm.write {
                self.realm.deleteAll()
                self.realm.add(Dog.dogs)
            }
        }

        it ("works well with `isManaged`, `isUnmanaged` operator") {
            let dog = Dog()
            expect(dog.isUnmanaged).to(beTrue())
            expect(dog.isManaged).to(beFalse())
            dog.name = "Taro"
            dog.age = 4
            let addTaro = Realm.IO.add(dog)
            try! self.realm.run(io: addTaro)
            let readTaro = RealmRead<Dog>.object(forPrimaryKey: "Taro")
            let result = try! self.realm.run(io: readTaro)
            expect(result?.isUnmanaged).to(beFalse())
            expect(result?.isManaged).to(beTrue())
        }

        it ("works well with `isManaged`, `isUnmanaged` operator") {
            let readAllDogs = RealmRead<Dog>.objects()
            let result = try! self.realm.run(io: readAllDogs)
            expect(result.isUnmanaged).to(beFalse())
            expect(result.isManaged).to(beTrue())
        }
    }
}
