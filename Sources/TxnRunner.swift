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
    public func runTxn<T>(txn: RealmReadTxn<T>) -> RealmResult<T> {
        return txn._run(self)
    }

    public func runTxn<T>(txn: RealmWriteTxn<T>) -> RealmResult<T> {
        return writeAndReturnResult {
            return txn._run(self)
        }
    }

    private func writeAndReturnResult<T>(_ f: () -> RealmResult<T>) -> RealmResult<T> {
        var result: RealmResult<T>!
        do {
            try self.write {
                result = f()
            }
        } catch let error as Realm.Error {
            result = .failure(error)
        } catch let error {
            result = .failure(Realm.Error(_nsError: error as NSError))
        }
        return result
    }
}
