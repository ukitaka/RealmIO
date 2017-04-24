//
//  RealmResult.swift
//  RealmTxn
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import Result
import Realm
import RealmSwift

public typealias RealmResult<T> = Result<T, Realm.Error>
