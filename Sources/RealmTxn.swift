//
//  RealmTxn.swift
//  RealmTxn
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift

public struct RealmTxn<RW, T> {
    internal let _run: (Realm) throws -> T

    public init(_ _run: @escaping (Realm) throws -> T) {
        self._run = _run
    }

    public func map<S>(_ f: @escaping (T) throws -> S) -> RealmTxn<RW, S> {
        return RealmTxn<RW, S> { realm in
            try f(self._run(realm))
        }
    }

    public func ask() -> RealmTxn<RW, Realm> {
        return RealmTxn<RW, Realm> { realm in
            return realm
        }
    }
}

// MARK: - typealias

public typealias RealmReadTxn<T> = RealmTxn<Read, T>

public typealias RealmWriteTxn<T> = RealmTxn<Write, T>

// MARK: - flatMap

public extension RealmTxn where RW == Read {
    // Read & Write -> Write
    public func flatMap<S>(_ f: @escaping (T) throws -> RealmWriteTxn<S>) -> RealmWriteTxn<S> {
        return RealmWriteTxn<S> { realm in
            try f(self._run(realm))._run(realm)
        }
    }

    // Read & Read -> Read
    public func flatMap<S>(_ f: @escaping (T) throws -> RealmReadTxn<S>) -> RealmReadTxn<S> {
        return RealmReadTxn<S> { realm in
            try f(self._run(realm))._run(realm)
        }
    }
}

public extension RealmTxn where RW == Write {
    // Write & Any -> Write
    public func flatMap<RW2, S>(_ f: @escaping (T) throws -> RealmTxn<RW2, S>) -> RealmWriteTxn<S> {
        return RealmWriteTxn<S> { realm in
            try f(self._run(realm))._run(realm)
        }
    }
}

// MARK: - Convert to WriteTxn

public extension RealmTxn where RW == Read {
    public var writeTxn: RealmWriteTxn<T> {
        return flatMap { t in
            RealmWriteTxn { realm in t }
        }
    }
}

// MARK: - modify

public extension RealmTxn where T: Object, RW == Write {
    public func modify(_ f: @escaping (T) -> ()) -> RealmWriteTxn<T> {
        return self.map { (obj: T) -> T in
            f(obj)
            return obj
        }
    }
}

public extension RealmTxn where T: Object, RW == Read {
    public func modify(_ f: @escaping (T) -> ()) -> RealmWriteTxn<T> {
        return self.writeTxn.modify(f)
    }
}
