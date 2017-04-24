//
//  TxnRunner.swift
//  RealmTxn
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import Foundation
import RealmSwift

public extension Realm {
    public func runTxn<T>(txn: RealmReadTxn<T>) throws -> T {
        return try txn._run(self)
    }

    public func runTxn<T>(txn: RealmWriteTxn<T>) throws -> T {
        return try writeAndReturn { try txn._run(self) }
    }
}
