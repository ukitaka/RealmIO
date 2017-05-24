//
//  RealmIO.swift
//  RealmIO
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift

public struct RealmIO<RW, T> {
    internal let _run: (Realm) throws -> T

    public init(_ _run: @escaping (Realm) throws -> T) {
        self._run = _run
    }

    public init(error: Error) {
        self._run = { _ in throw error }
    }

    public func map<S>(_ f: @escaping (T) throws -> S) -> RealmIO<RW, S> {
        return RealmIO<RW, S> { realm in
            try f(self._run(realm))
        }
    }

    public func ask() -> RealmIO<RW, Realm> {
        return RealmIO<RW, Realm> { realm in
            return realm
        }
    }
}

// MARK: - typealias

public typealias RealmRead<T> = RealmIO<Read, T>

public typealias RealmWrite<T> = RealmIO<Write, T>

// MARK: - flatMap

public extension RealmIO where RW == Read {
    // Read & Write -> Write
    public func flatMap<S>(_ f: @escaping (T) throws -> RealmWrite<S>) -> RealmWrite<S> {
        return RealmWrite<S> { realm in
            try f(self._run(realm))._run(realm)
        }
    }

    // Read & Read -> Read
    public func flatMap<S>(_ f: @escaping (T) throws -> RealmRead<S>) -> RealmRead<S> {
        return RealmRead<S> { realm in
            try f(self._run(realm))._run(realm)
        }
    }
}

public extension RealmIO where RW == Write {
    // Write & Any -> Write
    public func flatMap<RW2, S>(_ f: @escaping (T) throws -> RealmIO<RW2, S>) -> RealmWrite<S> {
        return RealmWrite<S> { realm in
            try f(self._run(realm))._run(realm)
        }
    }
}

// MARK: - Convert to WriteTxn

public extension RealmIO where RW == Read {
    public var writeTxn: RealmWrite<T> {
        return flatMap { t in
            RealmWrite { realm in t }
        }
    }
}

// MARK: - modify

public extension RealmIO where T: Object, RW == Write {
    public func modify(_ f: @escaping (T) -> ()) -> RealmWrite<T> {
        return self.map { (obj: T) -> T in
            f(obj)
            return obj
        }
    }
}

public extension RealmIO where T: Object, RW == Read {
    public func modify(_ f: @escaping (T) -> ()) -> RealmWrite<T> {
        return self.writeTxn.modify(f)
    }
}

// MARK: write or read

public extension RealmIO where RW == Read {
    var isRead: Bool {
        return true
    }

    var isWrite: Bool {
        return false
    }
}

public extension RealmIO where RW == Write {
    var isRead: Bool {
        return false
    }

    var isWrite: Bool {
        return true
    }
}
