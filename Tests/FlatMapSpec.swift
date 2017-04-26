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
    override func spec() {
        super.spec()
        it("has everything you need to get started") {
            let realm = try! Realm(configuration: Realm.Configuration(fileURL: nil, inMemoryIdentifier: "for test"))
            let txn = Realm.TxnOps.create(Dog.self, value: ["name": "dog_name_1"])
                .modify { dog in
                    dog.age = 1
                }
            try! realm.run(txn: txn)
        }
    }
}
