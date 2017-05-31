//
//  ReadWrite.swift
//  RealmIO
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import Foundation

// MARK: - Read

/// `Read` is used as `RW` type parameter of `RealmIO<RW, T>`
/// It represents that realm operation is readonly.
public struct Read { }

// MARK: - Write

/// `Read` is used as `RW` type parameter of `RealmIO<RW, T>`
/// It represents that realm operation needs to call `realm.write`.
public struct Write { }
