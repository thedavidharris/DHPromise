//
//  FutureSpec+Retry.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import XCTest
import Futura

class FutureRetryTests: XCTestCase {
    func testRetry() {
        let expectation = XCTestExpectation()
        var attemptsLeft = 3
        let future = Promise<Int>(error: TestError.test).futureResult
        future.retry(attempts: 3, retryBody: { () -> Future<Int> in
            attemptsLeft -= 1
            if attemptsLeft == 1 {
                return Promise(value: 4).futureResult
            } else {
                return Promise<Int>(error: TestError.test).futureResult
            }
        }).then({ (value) in
            XCTAssertEqual(value, 4)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func testRetryFailsAfterAllAttemptsUsed() {
        let expectation = XCTestExpectation()
        let future = Promise<Int>(error: TestError.test).futureResult
        
        future.retry(attempts: 3, retryBody: { () -> Future<Int> in
            return Promise<Int>(error: TestError.test).futureResult
        }).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 1)
    }
}
