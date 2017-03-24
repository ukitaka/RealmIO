//
//  RealmError.swift
//  FPRealm
//
//  Created by ukitaka on 2017/03/24.
//  Copyright © 2017年 waft. All rights reserved.
//

import Foundation

public enum RealmError: Error {
    case unknownError(Error)
    init(error: Error) {
        self = .unknownError(error)
    }
}
