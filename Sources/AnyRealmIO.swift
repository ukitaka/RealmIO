//
//  AnyRealmIO.swift
//  RealmIO
//
//  Created by ukitaka on 2017/05/11.
//  Copyright © 2018 waft. All rights reserved.
//

import RealmSwift

/// `AnyRealmIO` represents realm operation that cannot be determined `Read` or `Write` statically.
public struct AnyRealmIO<T> {
    internal let _run: (Realm) throws -> T

    public let isReadOnly: Bool

    @available(*, deprecated, renamed: "isReadOnly")
    public var isRead: Bool { return isReadOnly }

    public var isReadWrite: Bool {
        return !isReadOnly
    }

    @available(*, deprecated, renamed: "isReadWrite")
    public var isWrite: Bool { return isReadWrite }

    public init(io: RealmIO<ReadOnly, T>) {
        self._run = io._run
        self.isReadOnly = true
    }

    public init(io: RealmIO<ReadWrite, T>) {
        self._run = io._run
        self.isReadOnly = false
    }

    internal init(isReadOnly: Bool, run: @escaping (Realm) throws -> T) {
        self._run = run
        self.isReadOnly = isReadOnly
    }

    public init(error: Error, isReadOnly: Bool = true) {
        self._run = { _ in throw error }
        self.isReadOnly = isReadOnly
    }

    public func map<S>(_ f: @escaping (T) throws -> S) -> AnyRealmIO<S> {
        return AnyRealmIO<S>(isReadOnly: isReadOnly) { realm in
            try f(self._run(realm))
        }
    }

    public func flatMap<S>(_ f: @escaping (T) throws -> RealmRW<S>) -> RealmRW<S> {
        return RealmRW<S> { realm in
            try f(self._run(realm))._run(realm)
        }
    }

    public func flatMap<S>(_ f: @escaping (T) throws -> RealmRO<S>) -> AnyRealmIO<S> {
        return AnyRealmIO<S>(isReadOnly: isReadOnly) { realm in
            try f(self._run(realm))._run(realm)
        }
    }

    public func ask() -> AnyRealmIO<Realm> {
        return AnyRealmIO <Realm>(isReadOnly: isReadOnly) { realm in
            return realm
        }
    }
}
