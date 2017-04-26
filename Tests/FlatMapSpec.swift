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
        it("has everything you need to get started") {
            let txn = Realm.TxnOps.unmanaged(Dog.self, primaryKey: "dog_name_1")
                .modify { dog in dog.age = 1 }
                .flatMap(Realm.TxnOps.add)
            try! self.realm.run(txn: txn)
        }
    }
}
