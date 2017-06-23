//
//  AnyRealmIO.swift
//  RealmIO
//
//  Created by ukitaka on 2017/05/11.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift

/// `AnyRealmIO` represents realm operation that cannot be determined `Read` or `Write` statically.
public struct AnyRealmIO<T> {
    internal let _run: (Realm) throws -> T

    public let isRead: Bool

    public var isWrite: Bool {
        return !isRead
    }

    public init(io: RealmIO<ReadOnly, T>) {
        self._run = io._run
        self.isRead = true
    }

    public init(io: RealmIO<ReadWrite, T>) {
        self._run = io._run
        self.isRead = false
    }

    internal init(isRead: Bool, run: @escaping (Realm) throws -> T) {
        self._run = run
        self.isRead = isRead
    }

    public init(error: Error, isRead: Bool = true) {
        self._run = { _ in throw error }
        self.isRead = isRead
    }

    public func map<S>(_ f: @escaping (T) throws -> S) -> AnyRealmIO<S> {
        return AnyRealmIO<S>(isRead: isRead) { realm in
            try f(self._run(realm))
        }
    }

    public func flatMap<S>(_ f: @escaping (T) throws -> RealmWrite<S>) -> RealmWrite<S> {
        return RealmWrite<S> { realm in
            try f(self._run(realm))._run(realm)
        }
    }

    public func flatMap<S>(_ f: @escaping (T) throws -> RealmRead<S>) -> AnyRealmIO<S> {
        return AnyRealmIO<S>(isRead: isRead) { realm in
            try f(self._run(realm))._run(realm)
        }
    }

    public func ask() -> AnyRealmIO<Realm> {
        return AnyRealmIO <Realm>(isRead: isRead) { realm in
            return realm
        }
    }
}
