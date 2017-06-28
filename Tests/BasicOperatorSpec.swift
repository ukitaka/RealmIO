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
                let read = RealmIO<ReadOnly, Void>(error: error)
                expect { try self.realm.run(io: read) }.to(throwError())
                let write = RealmIO<ReadWrite, Void>(error: error)
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

                expect(io).to(beAnInstanceOf(RealmRO<String>.self))
                expect(result).to(equal("A"))
            }

            it("does not affect Read / Write type parameter") {
                let readIO = RealmRO<Void> { _ in }
                let writeIO = RealmRW<Void> { _ in }

               expect(readIO.map(id).isReadOnly).to(beTrue())
               expect(writeIO.map(id).isReadWrite).to(beTrue())
            }
        }

        describe("`ask` operator") {
            it("works well with `ask` operator") {
                let io = (RealmRO<Void> { _ in }).ask()
                expect(io).to(beAnInstanceOf(RealmRO<Realm>.self))
                expect(try! self.realm.run(io: io)).to(be(self.realm))
            }

            it("does not affect Read / Write type parameter") {
                let readIO = RealmRO<Void> { _ in }
                let writeIO = RealmRW<Void> { _ in }

                expect(readIO.ask().isReadOnly).to(beTrue())
                expect(writeIO.ask().isReadWrite).to(beTrue())
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
                let composedIO = RealmRO<String> { _ in "A" }
                    .flatMap { name in RealmRO<Dog>.object(forPrimaryKey: name) }

                let result = try! self.realm.run(io: composedIO)

                expect(result?.name).to(equal("A"))
                expect(result?.age).to(equal(10))
            }

            it("works well with `flatMap` operator (Read -> Write)") {
                let readDogIO = RealmRO<Dog>.object(forPrimaryKey: "A").map { $0! }
                
                func modifyDogIO(dog: Dog) -> RealmRW<Dog> {
                    return RealmRW<Dog> { realm in
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
                let composedIO = RealmRW<String> { _ in "A" }
                    .flatMap { _ in RealmRW { _ in "B" } }

                let result = try! self.realm.run(io: composedIO)
                expect(result).to(equal("B"))
            }
        }

        describe("`writeIO` operator") {
            it("works well with `writeIO` operator") {
                let readIO = RealmRO<Void> { _ in }
                expect(readIO.writeIO).to(beAnInstanceOf(RealmRW<Void>.self))
            }
        }

        describe("`modify` operator") {
            context("`modify` operator in `Read` io.") {
                it("works well with `modify` operator") {
                    let readDogIO = RealmRO<Dog>
                        .object(forPrimaryKey: "A")
                        .map { $0! }
                    
                    let io = readDogIO.modify { $0.age = 18 }
                    expect(io).to(beAnInstanceOf(RealmRW<Dog>.self))
                    expect(io.isReadWrite).to(beTrue())

                    let ageio = io.map { $0.age }
                    expect(try? self.realm.run(io: ageio)).to(equal(18))
                }
            }

            context("`modify` operator in `Write` io.") {
                it("works well with `modify` operator") {
                    let writeDogIO = RealmRO<Dog>
                        .object(forPrimaryKey: "A")
                        .map { $0! }
                        .writeIO

                    let io = writeDogIO.modify { $0.age = 19 }
                    expect(io).to(beAnInstanceOf(RealmRW<Dog>.self))
                    expect(io.isReadWrite).to(beTrue())

                    let ageio = io.map { $0.age }
                    expect(try? self.realm.run(io: ageio)).to(equal(19))
                }
            }
        }

        describe("`isReadWrite` and `isReadOnly` operator") {
            context("`isReadWrite` and `isReadOnly` operator in `Read` io.") {
                it("works well with `modify` operator") {
                    let io = RealmRO<Void> { _ in }
                    expect(io.isReadOnly).to(beTrue())
                    expect(io.isReadWrite).to(beFalse())
                }
            }

            context("`isReadWrite` and `isReadOnly` operator in `Write` io.") {
                it("works well with `modify` operator") {
                    let io = RealmRW<Void> { _ in }
                    expect(io.isReadOnly).to(beFalse())
                    expect(io.isReadWrite).to(beTrue())
                }
            }
        }
    }
}
