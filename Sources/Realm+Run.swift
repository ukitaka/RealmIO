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

    /// Run realm operation.
    ///
    /// - Parameter io: realm operation.
    /// - Returns: realm operation result.
    /// - Throws: `Realm.Error` or error thrown by user.
    @discardableResult
    public func run<T>(io: RealmRO<T>) throws -> T {
        return try io._run(self)
    }

    /// Run realm operation.
    ///
    /// - Parameter io: realm operation.
    /// - Returns: realm operation result.
    /// - Throws: `Realm.Error` or error thrown by user.
    @discardableResult
    public func run<T>(io: RealmRW<T>) throws -> T {
        return try writeAndReturn { try io._run(self) }
    }

    /// Run realm operation.
    ///
    /// - Parameter io: realm operation.
    /// - Returns: realm operation result.
    /// - Throws: `Realm.Error` or error thrown by user.
    @discardableResult
    public func run<T>(io: AnyRealmIO<T>) throws -> T {
        if io.isReadWrite {
            return try writeAndReturn { try io._run(self) }
        } else {
            return try io._run(self)
        }
    }
}

public extension Realm {

    /// Run realm operation with default realm instance.
    ///
    /// - Parameter io: realm operation.
    /// - Returns: realm operation result.
    /// - Throws: `Realm.Error` or error thrown by user.
    @discardableResult
    public static func run<T>(io: RealmRO<T>) throws -> T {
        return try io._run(Realm())
    }

    /// Run realm operation with default realm instance.
    ///
    /// - Parameter io: realm operation.
    /// - Returns: realm operation result.
    /// - Throws: `Realm.Error` or error thrown by user.
    @discardableResult
    public static func run<T>(io: RealmRW<T>) throws -> T {
        let realm = try Realm()
        return try realm.writeAndReturn { try io._run(realm) }
    }

    /// Run realm operation with default realm instance.
    ///
    /// - Parameter io: realm operation.
    /// - Returns: realm operation result.
    /// - Throws: `Realm.Error` or error thrown by user.
    @discardableResult
    public static func run<T>(io: AnyRealmIO<T>) throws -> T {
        if io.isReadWrite {
            let realm = try Realm()
            return try realm.writeAndReturn { try io._run(realm) }
        } else {
            return try io._run(Realm())
        }
    }
}
