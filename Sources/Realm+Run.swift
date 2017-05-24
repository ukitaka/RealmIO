//
//  Realm+Run.swift
//  RealmIO
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import Foundation
import RealmSwift

public extension Realm {
    @discardableResult
    public func run<T>(io: RealmRead<T>) throws -> T {
        return try io._run(self)
    }

    @discardableResult
    public func run<T>(io: RealmWrite<T>) throws -> T {
        return try writeAndReturn { try io._run(self) }
    }

    @discardableResult
    public func run<T>(io: AnyRealmIO<T>) throws -> T {
        if io.isWrite {
            return try writeAndReturn { try io._run(self) }
        } else {
            return try io._run(self)
        }
    }
}

public extension Realm {
    @discardableResult
    public static func run<T>(io: RealmRead<T>) throws -> T {
        return try io._run(Realm())
    }

    @discardableResult
    public static func run<T>(io: RealmWrite<T>) throws -> T {
        let realm = try Realm()
        return try realm.writeAndReturn { try io._run(realm) }
    }

    @discardableResult
    public static func run<T>(io: AnyRealmIO<T>) throws -> T {
        if io.isWrite {
            let realm = try Realm()
            return try realm.writeAndReturn { try io._run(realm) }
        } else {
            return try io._run(Realm())
        }
    }
}
