//
//  RealmTxn.swift
//  FPRealm
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift

public struct RealmTxn<RW, T> {
    internal let _run: (Realm) -> RealmResult<T>

    public init(_ _run: @escaping (Realm) -> RealmResult<T>) {
        self._run = _run
    }

    public static func success(_ _run: @escaping (Realm) -> T) -> RealmTxn<RW, T> {
        return RealmTxn<RW, T> { realm in
            RealmResult<T>.success(_run(realm))
        }
    }

    public func map<S>(_ f: @escaping (T) -> S) -> RealmTxn<RW, S> {
        return RealmTxn<RW, S> { realm in
            self._run(realm).map(f)
        }
    }

    public func ask() -> RealmTxn<RW, Realm> {
        return RealmTxn<RW, Realm> { realm in
            return .success(realm)
        }
    }
}

// MARK: - typealias

public typealias RealmReadTxn<T> = RealmTxn<Read, T>

public typealias RealmWriteTxn<T> = RealmTxn<Write, T>

// MARK: - flatMap

public extension RealmTxn where RW == Read {
    // Read & Write -> Write
    public func flatMap<S>(_ f: @escaping (T) -> RealmWriteTxn<S>) -> RealmWriteTxn<S> {
        return RealmWriteTxn<S> { realm in
            self._run(realm).flatMap { t in f(t)._run(realm) }
        }
    }

    // Read & Read -> Read
    public func flatMap<S>(_ f: @escaping (T) -> RealmReadTxn<S>) -> RealmReadTxn<S> {
        return RealmReadTxn<S> { realm in
            self._run(realm).flatMap { t in f(t)._run(realm) }
        }
    }
}

public extension RealmTxn where RW == Write {
    // Write & Any -> Write
    public func flatMap<RW2, S>(_ f: @escaping (T) -> RealmTxn<RW2, S>) -> RealmWriteTxn<S> {
        return RealmWriteTxn<S> { realm in
            self._run(realm).flatMap { t in f(t)._run(realm) }
        }
    }
}
