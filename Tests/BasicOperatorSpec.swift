//
//  BasicOperatorSpec.swift
//  RealmIO
//
//  Created by ukitaka on 2017/05/22.
//  Copyright © 2017年 waft. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
import RealmIO

class BasicOperatorSpec: QuickSpec {
    let realm = try! Realm(configuration: Realm.Configuration(fileURL: nil, inMemoryIdentifier: "for test"))

    override func spec() {
        super.spec()

        describe("`map` operator") {
            beforeEach {
                try! self.realm.write {
                    self.realm.deleteAll()
                    self.realm.add(Dog.dogs)
                }
            }

            it("works well with `map` operator") {
                let txn = Realm.IO
                    .object(ofType: Dog.self, forPrimaryKey: "A")
                    .map { $0?.name ?? "" }
                let result = try! self.realm.run(txn: txn)

                expect(txn).to(beAnInstanceOf(RealmRead<String>.self))
                expect(result).to(equal("A"))
            }

            it("does not affect Read / Write type parameter") {
                let readTxn = RealmRead<Void> { _ in }
                let writeTxn = RealmWrite<Void> { _ in }

               expect(readTxn.map(id).isRead).to(beTrue())
               expect(writeTxn.map(id).isWrite).to(beTrue())
            }
        }

        describe("`ask` operator") {
            it("works well with `ask` operator") {
                let txn = (RealmRead<Void> { _ in }).ask()
                expect(txn).to(beAnInstanceOf(RealmRead<Realm>.self))
                expect(try! self.realm.run(txn: txn)).to(be(self.realm))
            }

            it("does not affect Read / Write type parameter") {
                let readTxn = RealmRead<Void> { _ in }
                let writeTxn = RealmWrite<Void> { _ in }

                expect(readTxn.ask().isRead).to(beTrue())
                expect(writeTxn.ask().isWrite).to(beTrue())
            }
        }

        describe("`flatMap` operator") {
            beforeEach {
                try! self.realm.write {
                    self.realm.deleteAll()
                    self.realm.add(Dog.dogs)
                }
            }

            it("works well with `flatMap` operator") {
                let readDogATxn = RealmRead<Dog>.object(forPrimaryKey: "A").map { $0! }
                
                func modifyDogAgeTxn(dog: Dog) -> RealmWrite<Dog> {
                    return RealmWrite<Dog> { realm in
                        dog.age = 18
                        return dog
                    }
                }

                let txn = readDogATxn
                    .flatMap(modifyDogAgeTxn)
                    .map { $0.age }
                
                expect(try! self.realm.run(txn: txn)).to(equal(18))
            }
        }

        describe("`writeTxn` operator") {
            it("works well with `writeTxn` operator") {
                let readTxn = RealmRead<Void> { _ in }
                expect(readTxn.writeTxn).to(beAnInstanceOf(RealmWrite<Void>.self))
            }
        }

        describe("`modify` operator") {
            context("`modify` operator in `Read` txn.") {
                it("works well with `modify` operator") {
                    let readDogATxn = RealmRead<Dog>
                        .object(forPrimaryKey: "A")
                        .map { $0! }
                    
                    let txn = readDogATxn.modify { $0.age = 18 }
                    expect(txn).to(beAnInstanceOf(RealmWrite<Dog>.self))
                    expect(txn.isWrite).to(beTrue())

                    let ageTxn = txn.map { $0.age }
                    expect(try? self.realm.run(txn: ageTxn)).to(equal(18))
                }
            }

            context("`modify` operator in `Write` txn.") {
                it("works well with `modify` operator") {
                    let writeDogATxn = RealmRead<Dog>
                        .object(forPrimaryKey: "A")
                        .map { $0! }
                        .writeTxn

                    let txn = writeDogATxn.modify { $0.age = 19 }
                    expect(txn).to(beAnInstanceOf(RealmWrite<Dog>.self))
                    expect(txn.isWrite).to(beTrue())

                    let ageTxn = txn.map { $0.age }
                    expect(try? self.realm.run(txn: ageTxn)).to(equal(19))
                }
            }
        }

        describe("`isWrite` and `isRead` operator") {
            context("`isWrite` and `isRead` operator in `Read` txn.") {
                it("works well with `modify` operator") {
                    let txn = RealmRead<Void> { _ in }
                    expect(txn.isRead).to(beTrue())
                    expect(txn.isWrite).to(beFalse())
                }
            }

            context("`isWrite` and `isRead` operator in `Write` txn.") {
                it("works well with `modify` operator") {
                    let txn = RealmWrite<Void> { _ in }
                    expect(txn.isRead).to(beFalse())
                    expect(txn.isWrite).to(beTrue())
                }
            }
        }
    }
}
