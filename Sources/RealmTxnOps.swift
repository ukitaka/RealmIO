//
//  RealmTxnOps.swift
//  RealmTxn
//
//  Created by ukitaka on 2017/04/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift

// MARK: - TxnOps

public extension Realm {
    struct TxnOps { }
}

// MARK: - Write

public extension Realm.TxnOps {
    public static func add(_ object: Object) -> RealmWriteTxn<Void> {
        return RealmWriteTxn<Void> { realm in
            realm.add(object)
        }
    }

    public static func add(_ object: Object, update: Bool) -> RealmWriteTxn<Void> {
        return RealmWriteTxn<Void> { realm in
            realm.add(object, update: update)
        }
    }

    public static func add<S>(_ objects: S) -> RealmWriteTxn<Void> where S: Sequence, S.Iterator.Element: Object {
        return RealmWriteTxn<Void> { realm in
            realm.add(objects)
        }
    }

    public static func add<S>(_ objects: S, update: Bool) -> RealmWriteTxn<Void> where S: Sequence, S.Iterator.Element: Object {
        return RealmWriteTxn<Void> { realm in
            realm.add(objects, update: update)
        }
    }
    
    public static func create<T>(_ type: T.Type, value: Any = [:], update: Bool = false) -> RealmWriteTxn<T> where T: Object {
        return RealmWriteTxn<T> { realm in
            return realm.create(type, value: value, update: update)
        }
    }

    public static func dynamicCreate(_ typeName: String, value: Any = [:], update: Bool = false) -> RealmWriteTxn<DynamicObject> {
        return RealmWriteTxn<DynamicObject> { realm in
            return realm.dynamicCreate(typeName, value: value, update: update)
        }
    }

    public static func delete(_ object: Object) -> RealmWriteTxn<Void> {
        return RealmWriteTxn<Void> { realm in
            return realm.delete(object)
        }
    }

    public static func delete<S>(_ objects: S) -> RealmWriteTxn<Void> where S: Sequence, S.Iterator.Element: Object {
        return RealmWriteTxn<Void> { realm in
            return realm.delete(objects)
        }
    }

    public static func delete<T>(_ objects: List<T>) -> RealmWriteTxn<Void> where T: Object {
        return RealmWriteTxn<Void> { realm in
            return realm.delete(objects)
        }
    }

    public static func delete<T>(_ objects: Results<T>) -> RealmWriteTxn<Void> where T: Object {
        return RealmWriteTxn<Void> { realm in
            return realm.delete(objects)
        }
    }

    public static func deleteAll() -> RealmWriteTxn<Void> {
        return RealmWriteTxn<Void> { realm in
            return realm.deleteAll()
        }
    }
}

// MARK: - Read

public extension Realm.TxnOps {
    public static func objects<T>(_ type: T.Type) -> RealmReadTxn<Results<T>> where T: Object {
        return RealmReadTxn<Results<T>> { realm in
            return realm.objects(type)
        }
    }

    public static func dynamicObjects(_ typeName: String) -> RealmReadTxn<Results<DynamicObject>> {
        return RealmReadTxn<Results<DynamicObject>> { realm in
            return realm.dynamicObjects(typeName)
        }
    }

    public static func object<T, K>(ofType type: T.Type, forPrimaryKey key: K) -> RealmReadTxn<T?> where T: Object {
        return RealmReadTxn<T?> { realm in
            return realm.object(ofType: type, forPrimaryKey: key)
        }
    }
}

// MARK: - utils

public extension Realm.TxnOps {
    public static func unmanaged<T: Object>(_ type: T.Type) -> RealmWriteTxn<T> {
        return RealmWriteTxn<T> { _ in
            T()
        }
    }

    public static func unmanaged<T: Object, S>(_ type: T.Type, primaryKey: S) -> RealmWriteTxn<T> {
        return RealmWriteTxn<T> { _ in
            guard let primaryKeyName = T.primaryKey() else {
                return T()
            }
            let object = T()
            object.setValue(primaryKey, forKey: primaryKeyName)
            return object
        }
    }
}

public extension RealmTxn where T: Object {
    public static func object<K>(forPrimaryKey key: K) -> RealmReadTxn<T?> {
        return RealmReadTxn<T?> { realm in
            realm.object(ofType: T.self, forPrimaryKey: key)
        }
    }

    public static func objects() -> RealmReadTxn<Results<T>> {
        return RealmReadTxn<Results<T>> { realm in
            realm.objects(T.self)
        }
    }

    public static func create(value: Any = [:], update: Bool = false) -> RealmWriteTxn<T> {
        return RealmWriteTxn<T> { realm in
            return realm.create(T.self, value: value, update: update)
        }
    }
}
