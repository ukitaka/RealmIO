//
//  FlatMapSpec.swift
//  RealmTxn
//
//  Created by ukitaka on 2017/04/25.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift
import RealmTxn
import XCTest
import Quick
import Nimble

class FlatMapSpec: QuickSpec {
    let realm = try! Realm(configuration: Realm.Configuration(fileURL: nil, inMemoryIdentifier: "for test"))

    override func spec() {
        super.spec()
        it("should be `write` when compose `write` and `write`.") {
            let txn = Realm.TxnOps.unmanaged(Dog.self, primaryKey: "dog_name_1")
                .modify { dog in dog.age = 1 }
                .flatMap(Realm.TxnOps.add)

            expect(txn.isWrite).to(be(true))
        }

        it("should be `write` when compose `read` and `write`.") {
            let txn = Realm.TxnOps.object(ofType: Dog.self, forPrimaryKey: "dog_name_1")
                .map  { $0! }
                .flatMap(Realm.TxnOps.delete)

            expect(txn.isWrite).to(be(true))
        }

        it("should be `write` when compose `write` and `read`.") {
            let txn = Realm.TxnOps.unmanaged(Dog.self, primaryKey: "dog_name_1")
                .modify { dog in dog.age = 1 }
                .flatMap(Realm.TxnOps.add)
                .flatMap { _ in Realm.TxnOps.object(ofType: Dog.self, forPrimaryKey: "dog_name_1") }

            expect(txn.isWrite).to(be(true))
        }

        it("should be `read` when compose `read` and `read`.") {
            let txn = Realm.TxnOps.objects(Dog.self)
                .flatMap { _ in Realm.TxnOps.objects(Dog.self) }

            expect(txn.isWrite).to(be(false))
        }
    }
}
