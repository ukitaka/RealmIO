//
//  Realm+Operator.swift
//  RealmIO
//
//  Created by ukitaka on 2017/04/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift

// MARK: - IO

public extension Realm {
    struct IO { }
}

// MARK: - Write

public extension Realm.IO {
    public static func add(_ object: Object) -> RealmWrite<Void> {
        let ref = ThreadSafeReference(to: object)

        return RealmWrite<Void> { realm in
            guard let object = realm.resolve(ref) else {
                return // just return
            }
            realm.add(object)
        }
    }

    public static func add(_ object: Object, update: Bool) -> RealmWrite<Void> {
        let ref = ThreadSafeReference(to: object)

        return RealmWrite<Void> { realm in
            guard let object = realm.resolve(ref) else {
                return // just return
            }
            realm.add(object, update: update)
        }
    }

    public static func add<S>(_ objects: S) -> RealmWrite<Void> where S: Sequence, S.Iterator.Element: Object {
        let refs = objects.map(ThreadSafeReference.init)

        return RealmWrite<Void> { realm in
            realm.add(refs.flatMap(realm.resolve))
        }
    }

    public static func add<S>(_ objects: S, update: Bool) -> RealmWrite<Void> where S: Sequence, S.Iterator.Element: Object {
        let refs = objects.map(ThreadSafeReference.init)

        return RealmWrite<Void> { realm in
            realm.add(refs.flatMap(realm.resolve), update: update)
        }
    }
    
    public static func create<T>(_ type: T.Type, value: Any = [:], update: Bool = false) -> RealmWrite<T> where T: Object {
        return RealmWrite<T> { realm in
            return realm.create(type, value: value, update: update)
        }
    }

    public static func dynamicCreate(_ typeName: String, value: Any = [:], update: Bool = false) -> RealmWrite<DynamicObject> {
        return RealmWrite<DynamicObject> { realm in
            return realm.dynamicCreate(typeName, value: value, update: update)
        }
    }

    public static func delete(_ object: Object) -> RealmWrite<Void> {
        let ref = ThreadSafeReference(to: object)

        return RealmWrite<Void> { realm in
            guard let object = realm.resolve(ref) else {
                return // just return
            }
            return realm.delete(object)
        }
    }

    public static func delete<S>(_ objects: S) -> RealmWrite<Void> where S: Sequence, S.Iterator.Element: Object {
        let refs = objects.map(ThreadSafeReference.init)

        return RealmWrite<Void> { realm in
            return realm.delete(refs.flatMap(realm.resolve))
        }
    }

    public static func delete<T>(_ objects: List<T>) -> RealmWrite<Void> where T: Object {
        let refs = objects.map(ThreadSafeReference.init)

        return RealmWrite<Void> { realm in
            return realm.delete(refs.flatMap(realm.resolve))
        }
    }

    public static func delete<T>(_ objects: Results<T>) -> RealmWrite<Void> where T: Object {
        let refs = objects.map(ThreadSafeReference.init)

        return RealmWrite<Void> { realm in
            return realm.delete(refs.flatMap(realm.resolve))
        }
    }

    public static func deleteAll() -> RealmWrite<Void> {
        return RealmWrite<Void> { realm in
            return realm.deleteAll()
        }
    }
}

// MARK: - Read

public extension Realm.IO {
    public static func objects<T>(_ type: T.Type) -> RealmRead<Results<T>> where T: Object {
        return RealmRead<Results<T>> { realm in
            return realm.objects(type)
        }
    }

    public static func dynamicObjects(_ typeName: String) -> RealmRead<Results<DynamicObject>> {
        return RealmRead<Results<DynamicObject>> { realm in
            return realm.dynamicObjects(typeName)
        }
    }

    public static func object<T, K>(ofType type: T.Type, forPrimaryKey key: K) -> RealmRead<T?> where T: Object {
        return RealmRead<T?> { realm in
            return realm.object(ofType: type, forPrimaryKey: key)
        }
    }
}

// MARK: - utils

public extension Realm.IO {
    public static func unmanaged<T: Object>(_ type: T.Type) -> RealmWrite<T> {
        return RealmWrite<T> { _ in
            T()
        }
    }

    public static func unmanaged<T: Object, S>(_ type: T.Type, primaryKey: S) -> RealmWrite<T> {
        return RealmWrite<T> { _ in
            guard let primaryKeyName = T.primaryKey() else {
                return T()
            }
            let object = T()
            object.setValue(primaryKey, forKey: primaryKeyName)
            return object
        }
    }
}

public extension RealmIO where T: Object {
    public static func object<K>(forPrimaryKey key: K) -> RealmRead<T?> {
        return RealmRead<T?> { realm in
            realm.object(ofType: T.self, forPrimaryKey: key)
        }
    }

    public static func objects() -> RealmRead<Results<T>> {
        return RealmRead<Results<T>> { realm in
            realm.objects(T.self)
        }
    }

    public static func create(value: Any = [:], update: Bool = false) -> RealmWrite<T> {
        return RealmWrite<T> { realm in
            return realm.create(T.self, value: value, update: update)
        }
    }
}
