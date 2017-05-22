//
//  Utils.swift
//  RealmTxn
//
//  Created by ukitaka on 2017/05/22.
//  Copyright © 2017年 waft. All rights reserved.
//

import Foundation

func id<A>(_ a: A) -> A {
    return a
}

func const<A, B>(_ a: A) -> (B) -> A {
    return { _ in a }
}
