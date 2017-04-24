//
//  RealmTxnTests.swift
//  waft
//
//  Created by ukitaka on {TODAY}.
//  Copyright © 2017 waft. All rights reserved.
//

import Foundation
import XCTest
import RealmTxn

class RealmTxnTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //// XCTAssertEqual(RealmTxn().text, "Hello, World!")
    }
}

#if os(Linux)
extension RealmTxnTests {
    static var allTests : [(String, (RealmTxnTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
#endif
