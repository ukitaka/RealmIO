//
//  RealmIO.swift
//  RealmIO
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift

/// `RealmIO` represents realm operation.
/// - `RW` is actually `ReadOnly` or `ReadWrite`. It represents that operation is readonly or not.
/// - `T` is a return value type.
public struct RealmIO<RW: ReadWrite, T> {
    internal let _run: (Realm) throws -> T

    /// Obtains an instance of the `RealmIO<RW, T>` with given operation.
    ///
    /// - Parameter _run: realm operation. Actual `realm` instance is passed when call `realm.run(io:)`.
    public init(_ _run: @escaping (Realm) throws -> T) {
        self._run = _run
    }

    /// Constructs a failure operation with given `error`.
    ///
    /// - Parameter error: error that will be thrown when call `realm.run(io:)`
    public init(error: Error) {
        self._run = { _ in throw error }
    }

    /// Returns a new operation by mapping `T` value using `transform`.
    ///
    /// - Returns: New operation transformed by `transform`
    public func map<S>(_ transform: @escaping (T) throws -> S) -> RealmIO<RW, S> {
        return RealmIO<RW, S> { realm in
            try transform(self._run(realm))
        }
    }

    /// Returns a new operation that returns `Realm` instance.
    /// It is same as `ask` operator of reader monad.
    /// You can use this method when you want to access realm instance in operator such as `map`.
    public func ask() -> RealmIO<RW, Realm> {
        return RealmIO<RW, Realm> { realm in
            return realm
        }
    }
}

// MARK: - typealias

/// Alias of `RealmIO<Read, T>`
public typealias RealmRead<T> = RealmIO<ReadOnly, T>

/// Alias of `RealmIO<Write, T>`
public typealias RealmWrite<T> = RealmIO<ReadWrite, T>

// MARK: - flatMap

public extension RealmIO where RW: ReadOnly {
    /// Returns a new operator composed of this `Read` operation and given `Read` operation.
    ///
    /// - Returns: composed `Read` operation
    public func flatMap<S>(_ transform: @escaping (T) throws -> RealmRead<S>) -> RealmRead<S> {
        return RealmRead<S> { realm in
            try transform(self._run(realm))._run(realm)
        }
    }
}

public extension RealmIO {
    /// Returns a new operator composed of this `Write` operation and given operation.
    ///
    /// - Returns: composed `Write` operation
    public func flatMap<RW2, S>(_ transform: @escaping (T) throws -> RealmIO<RW2, S>) -> RealmWrite<S> {
        return RealmWrite<S> { realm in
            try transform(self._run(realm))._run(realm)
        }
    }
}

// MARK: - Convert to write operation

public extension RealmIO where RW: ReadOnly {
    /// Convert `Read` operation to `Write` operation.
    public var writeIO: RealmWrite<T> {
        return flatMap { t in
            RealmWrite { realm in t }
        }
    }
}

// MARK: - modify

public extension RealmIO where T: Object, RW: ReadWrite {
    /// Util method to modify `Object`
    public func modify(_ transform: @escaping (T) -> ()) -> RealmWrite<T> {
        return flatMap { t in
            RealmWrite { realm in
                transform(t)
                return t
            }
        }
    }
}

// MARK: write or read

public extension RealmIO {
    var isRead: Bool {
        return RW.self is ReadOnly.Type
    }

    var isWrite: Bool {
        return !(RW.self is ReadOnly.Type)
    }
}
