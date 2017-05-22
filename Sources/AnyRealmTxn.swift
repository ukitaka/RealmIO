//
//  AnyRealmTxn.swift
//  RealmTxn
//
//  Created by ukitaka on 2017/05/11.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift

public struct AnyRealmTxn<T> {
    internal let _run: (Realm) throws -> T

    public let isRead: Bool

    public var isWrite: Bool {
        return !isRead
    }

    public init(txn: RealmTxn<Read, T>) {
        self._run = txn._run
        self.isRead = true
    }

    public init(txn: RealmTxn<Write, T>) {
        self._run = txn._run
        self.isRead = false
    }

    internal init(isRead: Bool, run: @escaping (Realm) throws -> T) {
        self._run = run
        self.isRead = isRead
    }

    public init(error: Error, isRead: Bool = true) {
        self._run = { _ in throw error }
        self.isRead = true
    }

    public func map<S>(_ f: @escaping (T) throws -> S) -> AnyRealmTxn<S> {
        return AnyRealmTxn<S>(isRead: isRead) { realm in
            try f(self._run(realm))
        }
    }

    public func flatMap<S>(_ f: @escaping (T) throws -> RealmWriteTxn<S>) -> RealmWriteTxn<S> {
        return RealmWriteTxn<S> { realm in
            try f(self._run(realm))._run(realm)
        }
    }

    public func flatMap<S>(_ f: @escaping (T) throws -> RealmReadTxn<S>) -> AnyRealmTxn<S> {
        return AnyRealmTxn<S>(isRead: isRead) { realm in
            try f(self._run(realm))._run(realm)
        }
    }

    public func ask() -> AnyRealmTxn<Realm> {
        return AnyRealmTxn <Realm>(isRead: isRead) { realm in
            return realm
        }
    }
}
