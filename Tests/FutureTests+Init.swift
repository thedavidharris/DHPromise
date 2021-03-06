//
//  FutureSpec+Init.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import XCTest
import Futura

class FutureInitTests: XCTestCase {

    func testCompletedFutures() {
        let expectation1 = XCTestExpectation()
        let expectation2 = XCTestExpectation()

        let goodFuture = Promise<Int>({ (fulfill, reject) in
            fulfill(4)
        }).futureResult

        goodFuture.then { (_) in
            expectation1.fulfill()
        }


        let badFuture = Promise<Int>({ (fulfill, reject) in
            reject(TestError.test)
        }).futureResult

        badFuture.catch { (_) in
            expectation2.fulfill()
        }


        let successfulFuture = Promise(value: 4).futureResult

        let failedFuture = Promise<Int>(error: TestError.test).futureResult

        XCTAssertEqual(goodFuture.value, 4)
        XCTAssertEqual(successfulFuture.value, 4)
        XCTAssertEqual(badFuture.error as? TestError, TestError.test)
        XCTAssertEqual(failedFuture.error as? TestError, TestError.test)

        wait(for: [expectation1, expectation2], timeout: 4)
    }
    
    func testExecutedCallbacks() {
        let expectation1 = XCTestExpectation()
        let expectation2 = XCTestExpectation()
        let successfulFuture = Promise(value: 4).futureResult
        successfulFuture.then {
            XCTAssertEqual($0, 4)
            expectation1.fulfill()
        }
        
        let failedFuture = Promise<Int>(error: TestError.test).futureResult
        failedFuture.catch {
            XCTAssertEqual($0 as? TestError, TestError.test)
            expectation2.fulfill()
        }
        wait(for: [expectation1, expectation2], timeout: 1)
    }
}
