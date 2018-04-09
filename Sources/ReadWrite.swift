//
//  ReadWrite.swift
//  RealmIO
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2018 waft. All rights reserved.
//

import Foundation

// MARK: - ReadWrite

/// `ReadWrite` is used as `RW` type parameter of `RealmIO<RW, T>`
/// It represents that realm operation needs to call `realm.write`.
public class ReadWrite { }

@available(*, deprecated, renamed: "ReadWrite")
public typealias Write = ReadWrite

// MARK: - ReadOnly

/// `ReadOnly` is used as `RW` type parameter of `RealmIO<RW, T>`
/// It represents that realm operation is readonly.
public class ReadOnly: ReadWrite { }

@available(*, deprecated, renamed: "ReadOnly")
public typealias Read = ReadOnly
