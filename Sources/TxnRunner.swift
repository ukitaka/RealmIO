//
//  TxnRunner.swift
//  RealmTxn
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import Foundation
import RealmSwift

public extension Realm {
    @discardableResult
    public func run<T>(txn: RealmReadTxn<T>) throws -> T {
        return try txn._run(self)
    }

    @discardableResult
    public func run<T>(txn: RealmWriteTxn<T>) throws -> T {
        return try writeAndReturn { try txn._run(self) }
    }

    @discardableResult
    public func run<T>(txn: AnyRealmTxn<T>) throws -> T {
        if txn.isWrite {
            return try writeAndReturn { try txn._run(self) }
        } else {
            return try txn._run(self)
        }
    }
}

public extension Realm {
    @discardableResult
    public static func run<T>(txn: RealmReadTxn<T>) throws -> T {
        return try txn._run(Realm())
    }

    @discardableResult
    public static func run<T>(txn: RealmWriteTxn<T>) throws -> T {
        let realm = try Realm()
        return try realm.writeAndReturn { try txn._run(realm) }
    }

    @discardableResult
    public static func run<T>(txn: AnyRealmTxn<T>) throws -> T {
        if txn.isWrite {
            let realm = try Realm()
            return try realm.writeAndReturn { try txn._run(realm) }
        } else {
            return try txn._run(Realm())
        }
    }
}
