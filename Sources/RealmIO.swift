//
//  RealmIO.swift
//  RealmIO
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2018 waft. All rights reserved.
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

/// Alias of `RealmIO<ReadOnly, T>`
@available(*, deprecated, renamed: "RealmRO")
public typealias RealmRead<T> = RealmIO<ReadOnly, T>

public typealias RealmRO<T> = RealmIO<ReadOnly, T>


/// Alias of `RealmIO<ReadWrite, T>`
@available(*, deprecated, renamed: "RealmRW")
public typealias RealmWrite<T> = RealmIO<ReadWrite, T>

public typealias RealmRW<T> = RealmIO<ReadWrite, T>

// MARK: - flatMap

public extension RealmIO where RW: ReadOnly {
    /// Returns a new operator composed of this `Read` operation and given `Read` operation.
    ///
    /// - Returns: composed `ReadOnly` operation
    public func flatMap<S>(_ transform: @escaping (T) throws -> RealmRO<S>) -> RealmRO<S> {
        return RealmRO<S> { realm in
            try transform(self._run(realm))._run(realm)
        }
    }
}

public extension RealmIO {
    /// Returns a new operator composed of this `Write` operation and given operation.
    ///
    /// - Returns: composed `ReadWrite` operation
    public func flatMap<RW2, S>(_ transform: @escaping (T) throws -> RealmIO<RW2, S>) -> RealmRW<S> {
        return RealmRW<S> { realm in
            try transform(self._run(realm))._run(realm)
        }
    }
}

// MARK: - Convert to write operation

public extension RealmIO where RW: ReadOnly {
    /// Convert `Read` operation to `Write` operation.
    public var writeIO: RealmRW<T> {
        return flatMap { t in
            RealmRW { realm in t }
        }
    }
}

// MARK: - modify

public extension RealmIO where T: Object {
    /// Util method to modify `Object`
    public func modify(_ transform: @escaping (T) -> ()) -> RealmRW<T> {
        return flatMap { t in
            RealmRW { realm in
                transform(t)
                return t
            }
        }
    }
}

// MARK: readonly or readwrite

public extension RealmIO {
    @available(*, deprecated, renamed: "isReadOnly")
    var isRead: Bool {
        return RW.self is ReadOnly.Type
    }

    var isReadOnly: Bool {
        return RW.self is ReadOnly.Type
    }

    @available(*, deprecated, renamed: "isReadWrite")
    var isWrite: Bool {
        return !(RW.self is ReadOnly.Type)
    }

    var isReadWrite: Bool {
        return !(RW.self is ReadOnly.Type)
    }
}
