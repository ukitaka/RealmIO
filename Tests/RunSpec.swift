//
//  RunSpec.swift
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

class RunSpec: QuickSpec {
    let realm = try! Realm(configuration: Realm.Configuration(fileURL: nil, inMemoryIdentifier: "for test"))
    struct MyError: Error { }

    override func spec() {
        super.spec()
        describe("realm.run(io:)") {
            let error = MyError()
            let read = RealmRO<Void> { _ in }
            let write = RealmRW<Void> { _ in }
            let anyRead = AnyRealmIO<Void>(io: read)
            let anyWrite = AnyRealmIO<Void>(io: write)
            let errorIO = RealmRO<Void>(error: error)

            expect { try self.realm.run(io: read)     }.notTo(throwError())
            expect { try self.realm.run(io: write)    }.notTo(throwError())
            expect { try self.realm.run(io: anyRead)  }.notTo(throwError())
            expect { try self.realm.run(io: anyWrite) }.notTo(throwError())
            expect { try self.realm.run(io: errorIO)  }.to(throwError())
        }

        describe("Realm.run(io:)") {
            let error = MyError()
            let read = RealmRO<Void> { _ in }
            let write = RealmRW<Void> { _ in }
            let anyRead = AnyRealmIO<Void>(io: read)
            let anyWrite = AnyRealmIO<Void>(io: write)
            let errorIO = RealmRO<Void>(error: error)

            expect { try Realm.run(io: read)     }.notTo(throwError())
            expect { try Realm.run(io: write)    }.notTo(throwError())
            expect { try Realm.run(io: anyRead)  }.notTo(throwError())
            expect { try Realm.run(io: anyWrite) }.notTo(throwError())
            expect { try Realm.run(io: errorIO)  }.to(throwError())

            afterEach {
                try! Realm().write {
                    try! Realm().deleteAll()
                }
            }
        }
    }
}
