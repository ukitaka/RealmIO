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

        let readIO = RealmRead<Void> { _ in }
        let writeIO = RealmWrite<Void> { _ in }
        let readAnyIO = AnyRealmIO<Void>(io: readIO)
        let writeAnyIO = AnyRealmIO<Void>(io: writeIO)

        it("should be `write` when compose `write` and `write`.") {
            let io = writeIO.flatMap { _ in writeIO }
            expect(io.isWrite).to(beTrue())
        }

        it("should be `write` when compose `read` and `write`.") {
            let io = readIO.flatMap { _ in writeIO }
            expect(io.isWrite).to(beTrue())
        }

        it("should be `write` when compose `write` and `read`.") {
            let io = writeIO.flatMap { _ in readIO }
            expect(io.isWrite).to(beTrue())
        }

        it("should be `read` when compose `read` and `read`.") {
            let io = readIO.flatMap { _ in readIO }
            expect(io.isRead).to(beTrue())
        }

        it("should be `read` when compose `any(read)` and `read`.") {
            let io = readAnyIO.flatMap { _ in readIO }
            expect(io.isRead).to(beTrue())
        }

        it("should be `write` when compose `any(read)` and `write`.") {
            let io = readAnyIO.flatMap { _ in writeIO }
            expect(io.isWrite).to(beTrue())
        }

        it("should be `write` when compose `any(write)` and `read`.") {
            let io = writeAnyIO.flatMap { _ in readIO }
            expect(io.isWrite).to(beTrue())
        }

        it("should be `write` when compose `any(write)` and `write`.") {
            let io = writeAnyIO.flatMap { _ in writeIO }
            expect(io.isWrite).to(beTrue())
        }
    }
}
