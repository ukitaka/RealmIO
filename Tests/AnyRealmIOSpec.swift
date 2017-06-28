//
//  AnyRealmIOSpec.swift
//  RealmIO
//
//  Created by ukitaka on 2017/05/31.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift
import RealmIO
import XCTest
import Quick
import Nimble

class AnyRealmIOSpec: QuickSpec {
    let realm = try! Realm(configuration: Realm.Configuration(fileURL: nil, inMemoryIdentifier: "for test"))

    override func spec() {
        super.spec()

        it("works well with `init(io:)`") {
            let read = AnyRealmIO(io: RealmRO<Void> { _ in })
            expect(read.isReadOnly).to(beTrue())
            expect(try! self.realm.run(io: read)).notTo(throwError())

            let write = AnyRealmIO(io: RealmRW<Void> { _ in })
            expect(write.isReadWrite).to(beTrue())
            expect(try! self.realm.run(io: write)).notTo(throwError())
        }

        it("works well with `init(error:isReadOnly)`") {
            struct MyError: Error { }
            let error = MyError()
            let read = AnyRealmIO<Void>(error: error)
            expect(read.isReadOnly).to(beTrue())
            expect { try self.realm.run(io: read) }.to(throwError())

            let write = AnyRealmIO<Void>(error: error, isReadOnly: false)
            expect(write.isReadWrite).to(beTrue())
            expect { try self.realm.run(io: write) }.to(throwError())
        }

        it("works well with `map` operator") {
            let read = AnyRealmIO<Void>(io: RealmRO<Void> { _ in }).map { _ in "hello" }
            expect(try! self.realm.run(io: read)).to(equal("hello"))
        }

        it("works well with `flatMap` operator") {
            let read = RealmRO<String> { _ in "read" }
            let write = RealmRW<String> { _ in "write" }
            let io1 = AnyRealmIO(io: read).flatMap { _ in  write }
            expect(io1).to(beAnInstanceOf(RealmRW<String>.self))
            expect(try! self.realm.run(io: io1)).to(equal("write"))

            let io2 = AnyRealmIO(io: read).flatMap { _ in read }
            expect(io2).to(beAnInstanceOf(AnyRealmIO<String>.self))
            expect(try! self.realm.run(io: io2)).to(equal("read"))
        }

        it("works well with `ask` operator") {
            let read = RealmRO<String> { _ in "read" }
            let io = AnyRealmIO(io: read).ask()
            expect(io).to(beAnInstanceOf(AnyRealmIO<Realm>.self))
            expect(try! self.realm.run(io: io)).to(equal(self.realm))
        }
    }
}
