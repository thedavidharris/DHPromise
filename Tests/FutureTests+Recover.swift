//
//  FutureSpec+Recover.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import XCTest
import Futura

class FutureRecoverTests: XCTestCase {
    func testRecover() {
        let expectation = XCTestExpectation()
        let future = Promise<Int>(error: TestError.test).futureResult
        future.recover({ _ -> Future<Int> in
            Promise(value: 4).futureResult
        }).then({ (value) in
            XCTAssertEqual(value, 4)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func testFailedRecover() {
        let expectation = XCTestExpectation()
        let future = Promise<Int>(error: TestError.test).futureResult
        future.recover({ _ -> Future<Int> in
            try throwingFuture(successValue: 12, shouldThrow: true)
        }).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
}
