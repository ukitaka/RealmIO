//
//  Object+Util.swift
//  RealmIO
//
//  Created by ukitaka on 2017/05/30.
//  Copyright © 2017年 waft. All rights reserved.
//

import RealmSwift

internal extension Object {
    var isUnmanaged: Bool {
        return realm == nil
    }

    var isManaged: Bool {
        return !isUnmanaged
    }

    var isInWriteTransaction: Bool {
        return realm?.isInWriteTransaction == true
    }
}

internal extension Sequence where Self.Iterator.Element: Object {
    var isUnmanaged: Bool {
        return contains { $0.isUnmanaged }
    }

    var isManaged: Bool {
        return !isUnmanaged
    }

    var isInWriteTransaction: Bool {
        return contains { $0.isInWriteTransaction == true }
    }
}
