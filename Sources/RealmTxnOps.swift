//
//  RealmTxnOps.swift
//  RealmTxn
//
//  Created by ukitaka on 2017/04/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift

public struct RealmTxnOps { }

// MARK: - Write

public extension RealmTxnOps {
    public func add(_ object: @escaping @autoclosure () -> Object, update: Bool = false) -> RealmWriteTxn<Void> {
        return RealmWriteTxn<Void> { realm in
            realm.add(object(), update: update)
        }
    }

    public func add<S>(_ objects: @escaping @autoclosure () -> S, update: Bool = false) -> RealmWriteTxn<Void> where S: Sequence, S.Iterator.Element: Object {
        return RealmWriteTxn<Void> { realm in
            realm.add(objects(), update: update)
        }
    }
    
    public func create<T>(_ type: T.Type, value: Any = [:], update: Bool = false) -> RealmWriteTxn<T> where T: Object {
        return RealmWriteTxn<T> { realm in
            return realm.create(type, value: value, update: update)
        }
    }

    public func dynamicCreate(_ typeName: String, value: Any = [:], update: Bool = false) -> RealmWriteTxn<DynamicObject> {
        return RealmWriteTxn<DynamicObject> { realm in
            return realm.dynamicCreate(typeName, value: value, update: update)
        }
    }

    public func delete(_ object: Object) -> RealmWriteTxn<Void> {
        return RealmWriteTxn<Void> { realm in
            return realm.delete(object)
        }
    }

    public func delete<S>(_ objects: S) -> RealmWriteTxn<Void> where S: Sequence, S.Iterator.Element: Object {
        return RealmWriteTxn<Void> { realm in
            return realm.delete(objects)
        }
    }

    public func delete<T>(_ objects: List<T>) -> RealmWriteTxn<Void> where T: Object {
        return RealmWriteTxn<Void> { realm in
            return realm.delete(objects)
        }
    }

    public func delete<T>(_ objects: Results<T>) -> RealmWriteTxn<Void> where T: Object {
        return RealmWriteTxn<Void> { realm in
            return realm.delete(objects)
        }
    }

    public func deleteAll() -> RealmWriteTxn<Void> {
        return RealmWriteTxn<Void> { realm in
            return realm.deleteAll()
        }
    }
}

// MARK: - Read

public extension RealmTxnOps {
    public func objects<T>(_ type: T.Type) -> RealmReadTxn<Results<T>> where T: Object {
        return RealmReadTxn<Results<T>> { realm in
            return realm.objects(type)
        }
    }

    public func dynamicObjects(_ typeName: String) -> RealmReadTxn<Results<DynamicObject>> {
        return RealmReadTxn<Results<DynamicObject>> { realm in
            return realm.dynamicObjects(typeName)
        }
    }

    public func object<T, K>(ofType type: T.Type, forPrimaryKey key: K) -> RealmReadTxn<T?> where T: Object {
        return RealmReadTxn<T?> { realm in
            return realm.object(ofType: type, forPrimaryKey: key)
        }
    }
}

// MARK: -

extension Realm {
    public static var txn: RealmTxnOps {
        return RealmTxnOps()
    }
}

// MARK: - utils

public extension RealmTxn where T: Object {
    public func object<K>(forPrimaryKey key: K) -> RealmReadTxn<T?> {
        return RealmReadTxn<T?> { realm in
            realm.object(ofType: T.self, forPrimaryKey: key)
        }
    }

    public func objects() -> RealmReadTxn<Results<T>> {
        return RealmReadTxn<Results<T>> { realm in
            realm.objects(T.self)
        }
    }

    public func create(value: Any = [:], update: Bool = false) -> RealmWriteTxn<T> {
        return RealmWriteTxn<T> { realm in
            return realm.create(T.self, value: value, update: update)
        }
    }
}
