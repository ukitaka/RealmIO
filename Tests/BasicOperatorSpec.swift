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

        describe("`init(error:)` operator") {
            it("should throw Error when run io that initalized with `init(error:)`") {
                struct MyError: Error { }
                let error = MyError()
                let read = RealmIO<Read, Void>(error: error)
                expect { try self.realm.run(io: read) }.to(throwError())
                let write = RealmIO<Write, Void>(error: error)
                expect { try self.realm.run(io: write) }.to(throwError())
            }
        }

        describe("`map` operator") {
            beforeEach {
                try! self.realm.write {
                    self.realm.deleteAll()
                    self.realm.add(Dog.dogs)
                }
            }

            it("works well with `map` operator") {
                let io = Realm.IO
                    .object(ofType: Dog.self, forPrimaryKey: "A")
                    .map { $0?.name ?? "" }
                let result = try! self.realm.run(io: io)

                expect(io).to(beAnInstanceOf(RealmRead<String>.self))
                expect(result).to(equal("A"))
            }

            it("does not affect Read / Write type parameter") {
                let readIO = RealmRead<Void> { _ in }
                let writeIO = RealmWrite<Void> { _ in }

               expect(readIO.map(id).isRead).to(beTrue())
               expect(writeIO.map(id).isWrite).to(beTrue())
            }
        }

        describe("`ask` operator") {
            it("works well with `ask` operator") {
                let io = (RealmRead<Void> { _ in }).ask()
                expect(io).to(beAnInstanceOf(RealmRead<Realm>.self))
                expect(try! self.realm.run(io: io)).to(be(self.realm))
            }

            it("does not affect Read / Write type parameter") {
                let readIO = RealmRead<Void> { _ in }
                let writeIO = RealmWrite<Void> { _ in }

                expect(readIO.ask().isRead).to(beTrue())
                expect(writeIO.ask().isWrite).to(beTrue())
            }
        }

        describe("`flatMap` operator") {
            beforeEach {
                try! self.realm.write {
                    self.realm.deleteAll()
                    self.realm.add(Dog.dogs)
                }
            }

            it("works well with `flatMap` operator (Read -> Read)") {
                let composedIO = RealmRead<String> { _ in "A" }
                    .flatMap { name in RealmRead<Dog>.object(forPrimaryKey: name) }

                let result = try! self.realm.run(io: composedIO)

                expect(result?.name).to(equal("A"))
                expect(result?.age).to(equal(10))
            }

            it("works well with `flatMap` operator (Read -> Write)") {
                let readDogIO = RealmRead<Dog>.object(forPrimaryKey: "A").map { $0! }
                
                func modifyDogIO(dog: Dog) -> RealmWrite<Dog> {
                    return RealmWrite<Dog> { realm in
                        dog.age = 18
                        return dog
                    }
                }

                let io = readDogIO
                    .flatMap(modifyDogIO)
                    .map { $0.age }
                
                expect(try! self.realm.run(io: io)).to(equal(18))
            }

            it("works well with `flatMap` operator (Write -> Any)") {
                let composedIO = RealmWrite<String> { _ in "A" }
                    .flatMap { _ in RealmWrite { _ in "B" } }

                let result = try! self.realm.run(io: composedIO)
                expect(result).to(equal("B"))
            }
        }

        describe("`writeIO` operator") {
            it("works well with `writeIO` operator") {
                let readIO = RealmRead<Void> { _ in }
                expect(readIO.writeIO).to(beAnInstanceOf(RealmWrite<Void>.self))
            }
        }

        describe("`modify` operator") {
            context("`modify` operator in `Read` io.") {
                it("works well with `modify` operator") {
                    let readDogIO = RealmRead<Dog>
                        .object(forPrimaryKey: "A")
                        .map { $0! }
                    
                    let io = readDogIO.modify { $0.age = 18 }
                    expect(io).to(beAnInstanceOf(RealmWrite<Dog>.self))
                    expect(io.isWrite).to(beTrue())

                    let ageio = io.map { $0.age }
                    expect(try? self.realm.run(io: ageio)).to(equal(18))
                }
            }

            context("`modify` operator in `Write` io.") {
                it("works well with `modify` operator") {
                    let writeDogIO = RealmRead<Dog>
                        .object(forPrimaryKey: "A")
                        .map { $0! }
                        .writeIO

                    let io = writeDogIO.modify { $0.age = 19 }
                    expect(io).to(beAnInstanceOf(RealmWrite<Dog>.self))
                    expect(io.isWrite).to(beTrue())

                    let ageio = io.map { $0.age }
                    expect(try? self.realm.run(io: ageio)).to(equal(19))
                }
            }
        }

        describe("`isWrite` and `isRead` operator") {
            context("`isWrite` and `isRead` operator in `Read` io.") {
                it("works well with `modify` operator") {
                    let io = RealmRead<Void> { _ in }
                    expect(io.isRead).to(beTrue())
                    expect(io.isWrite).to(beFalse())
                }
            }

            context("`isWrite` and `isRead` operator in `Write` io.") {
                it("works well with `modify` operator") {
                    let io = RealmWrite<Void> { _ in }
                    expect(io.isRead).to(beFalse())
                    expect(io.isWrite).to(beTrue())
                }
            }
        }
    }
}
