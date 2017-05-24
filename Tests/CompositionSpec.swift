//
//  CompositionSpec.swift
//  RealmIO
//
//  Created by ukitaka on 2017/04/25.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift
import RealmIO
import XCTest
import Quick
import Nimble

class CompositionSpec: QuickSpec {
    let realm = try! Realm(configuration: Realm.Configuration(fileURL: nil, inMemoryIdentifier: "for test"))

    override func spec() {
        super.spec()

        let readTxn = RealmRead<Void> { _ in }
        let writeTxn = RealmWrite<Void> { _ in }
        let readAnyTxn = AnyRealmIO<Void>(txn: readTxn)
        let writeAnyTxn = AnyRealmIO<Void>(txn: writeTxn)

        it("should be `write` when compose `write` and `write`.") {
            let txn = writeTxn.flatMap { _ in writeTxn }
            expect(txn.isWrite).to(beTrue())
        }

        it("should be `write` when compose `read` and `write`.") {
            let txn = readTxn.flatMap { _ in writeTxn }
            expect(txn.isWrite).to(beTrue())
        }

        it("should be `write` when compose `write` and `read`.") {
            let txn = writeTxn.flatMap { _ in readTxn }
            expect(txn.isWrite).to(beTrue())
        }

        it("should be `read` when compose `read` and `read`.") {
            let txn = readTxn.flatMap { _ in readTxn }
            expect(txn.isRead).to(beTrue())
        }

        it("should be `read` when compose `any(read)` and `read`.") {
            let txn = readAnyTxn.flatMap { _ in readTxn }
            expect(txn.isRead).to(beTrue())
        }

        it("should be `write` when compose `any(read)` and `write`.") {
            let txn = readAnyTxn.flatMap { _ in writeTxn }
            expect(txn.isWrite).to(beTrue())
        }

        it("should be `write` when compose `any(write)` and `read`.") {
            let txn = writeAnyTxn.flatMap { _ in readTxn }
            expect(txn.isWrite).to(beTrue())
        }

        it("should be `write` when compose `any(write)` and `write`.") {
            let txn = writeAnyTxn.flatMap { _ in writeTxn }
            expect(txn.isWrite).to(beTrue())
        }
    }
}
