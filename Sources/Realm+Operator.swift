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

    /// Adds object into the Realm.
    ///
    /// - Parameter object: The object to be added to this Realm.
    /// - Returns: `Write` operation
    public static func add(_ object: Object) -> RealmWrite<Void> {
        guard object.isManaged else {
            return RealmWrite<Void> { realm in realm.add(object) }
        }

        let ref = ThreadSafeReference(to: object)

        return RealmWrite<Void> { realm in
            guard let object = realm.resolve(ref) else {
                return // just return
            }
            realm.add(object)
        }
    }

    /// Adds or updates an existing object into the Realm.
    ///
    /// - Parameter object: The object to be added to this Realm.
    /// - Parameter update: If `true`, the Realm will try to find an existing copy of the object
    ///     (with the same primary key), and update it. Otherwise, the object will be added.
    /// - Returns: `Write` operation
    public static func add(_ object: Object, update: Bool) -> RealmWrite<Void> {
        guard object.isManaged else {
            return RealmWrite<Void> { realm in realm.add(object, update: update) }
        }

        let ref = ThreadSafeReference(to: object)

        return RealmWrite<Void> { realm in
            guard let object = realm.resolve(ref) else {
                return // just return
            }
            realm.add(object, update: update)
        }
    }

    /// Adds all the objects in a collection into the Realm.
    ///
    /// - Parameter objects: A sequence which contains objects to be added to the Realm.
    /// - Returns: `Write` operation
    public static func add<S>(_ objects: S) -> RealmWrite<Void> where S: Sequence, S.Iterator.Element: Object {
        guard objects.isManaged else {
            return RealmWrite<Void> { realm in realm.add(objects) }
        }

        let refs = objects.map(ThreadSafeReference.init)

        return RealmWrite<Void> { realm in
            realm.add(refs.flatMap(realm.resolve))
        }
    }

    /// Adds or updates all the objects in a collection into the Realm.
    ///
    /// - Parameter objects: A sequence which contains objects to be added to the Realm.
    /// - Parameter update: If `true`, objects that are already in the Realm will be updated instead of added anew.
    /// - Returns: `Write` operation
    public static func add<S>(_ objects: S, update: Bool) -> RealmWrite<Void> where S: Sequence, S.Iterator.Element: Object {
        guard objects.isManaged else {
            return RealmWrite<Void> { realm in realm.add(objects, update: update) }
        }

        let refs = objects.map(ThreadSafeReference.init)

        return RealmWrite<Void> { realm in
            realm.add(refs.flatMap(realm.resolve), update: update)
        }
    }

    /// Creates or updates a Realm object with a given value, adding it to the Realm and returning it.
    ///
    /// - parameter type:   The type of the object to create.
    /// - parameter value:  The value used to populate the object.
    /// - parameter update: If `true`, the Realm will try to find an existing copy of the object (with the same primary
    /// key), and update it. Otherwise, the object will be added.
    /// - returns: `Write` operation
    public static func create<T>(_ type: T.Type, value: Any = [:], update: Bool = false) -> RealmWrite<T> where T: Object {
        return RealmWrite<T> { realm in
            return realm.create(type, value: value, update: update)
        }
    }

    /// This method is useful only in specialized circumstances, for example, when building
    /// components that integrate with Realm. If you are simply building an app on Realm, it is
    /// recommended to use the typed method `create(_:value:update:)`.
    ///
    /// - parameter className:  The class name of the object to create.
    /// - parameter value:      The value used to populate the object.
    /// - parameter update:     If true will try to update existing objects with the same primary key.
    /// - returns: `Write` operation
    public static func dynamicCreate(_ typeName: String, value: Any = [:], update: Bool = false) -> RealmWrite<DynamicObject> {
        return RealmWrite<DynamicObject> { realm in
            return realm.dynamicCreate(typeName, value: value, update: update)
        }
    }

    /// Deletes an object from the Realm. Once the object is deleted it is considered invalidated.
    ///
    /// - parameter object: The object to be deleted.
    /// - returns: `Write` operation
    public static func delete(_ object: Object) -> RealmWrite<Void> {
        let ref = ThreadSafeReference(to: object)

        return RealmWrite<Void> { realm in
            guard let object = realm.resolve(ref) else {
                return // just return
            }
            return realm.delete(object)
        }
    }

    /// Deletes zero or more objects from the Realm.
    ///
    /// - parameter objects: The objects to be deleted. This can be a `List<Object>`,
    ///     `Results<Object>`, or any other Swift `Sequence` whose
    ///     elements are `Object`s (subject to the caveats above).
    /// - returns: `Write` operation
    public static func delete<S: Sequence>(_ objects: S) -> RealmWrite<Void> where S.Iterator.Element: Object {
        let refs = objects.map(ThreadSafeReference.init)

        return RealmWrite<Void> { realm in
            return realm.delete(refs.flatMap(realm.resolve))
        }
    }

    /// Deletes zero or more objects from the Realm.
    ///
    /// - parameter objects: A list of objects to delete.
    /// - returns: `Write` operation
    public static func delete<T: Object>(_ objects: List<T>) -> RealmWrite<Void> {
        let refs = objects.map(ThreadSafeReference.init)

        return RealmWrite<Void> { realm in
            return realm.delete(refs.flatMap(realm.resolve))
        }
    }

    /// Deletes zero or more objects from the Realm.
    ///
    /// - parameter objects: A `Results` containing the objects to be deleted.
    /// - returns: `Write` operation
    public static func delete<T: Object>(_ objects: Results<T>) -> RealmWrite<Void> {
        let refs = objects.map(ThreadSafeReference.init)

        return RealmWrite<Void> { realm in
            return realm.delete(refs.flatMap(realm.resolve))
        }
    }

    /// Deletes all objects from the Realm.
    ///
    /// - returns: `Write` operation
    public static func deleteAll() -> RealmWrite<Void> {
        return RealmWrite<Void> { realm in
            return realm.deleteAll()
        }
    }
}

// MARK: - Read

public extension Realm.IO {

    /// Returns all objects of the given type stored in the Realm.
    ///
    /// - parameter type: The type of the objects to be returned.
    /// - returns: `Read` operation
    public static func objects<T: Object>(_ type: T.Type) -> RealmRead<Results<T>> {
        return RealmRead<Results<T>> { realm in
            return realm.objects(type)
        }
    }

    /// Returns all objects for a given class name in the Realm.
    ///
    /// - parameter typeName: The class name of the objects to be returned.
    /// - returns: `Read` operation
    public static func dynamicObjects(_ typeName: String) -> RealmRead<Results<DynamicObject>> {
        return RealmRead<Results<DynamicObject>> { realm in
            return realm.dynamicObjects(typeName)
        }
    }

    /// Retrieves the single instance of a given object type with the given primary key from the Realm.
    ///
    /// - parameter type: The type of the object to be returned.
    /// - parameter key:  The primary key of the desired object.
    /// - returns: `Read` operation
    public static func object<T: Object, K>(ofType type: T.Type, forPrimaryKey key: K) -> RealmRead<T?> {
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
