//
//  FPRealmTests.swift
//  waft
//
//  Created by ukitaka on {TODAY}.
//  Copyright © 2017 waft. All rights reserved.
//

import Foundation
import XCTest
import FPRealm

class FPRealmTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //// XCTAssertEqual(FPRealm().text, "Hello, World!")
    }
}

#if os(Linux)
extension FPRealmTests {
    static var allTests : [(String, (FPRealmTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
#endif
