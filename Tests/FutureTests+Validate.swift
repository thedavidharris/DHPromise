//
//  FutureSpec+Validate.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import XCTest
import Futura

class FutureValidateTests: XCTestCase {
    func testPassesValidation() {
        let expecation = XCTestExpectation()
        let future = Promise(value: 4).futureResult
        future.validate({ (value) -> Bool in
            return value % 2 == 0
        }).then({ (value) in
            XCTAssertEqual(value, 4)
            expecation.fulfill()
        })
        wait(for: [expecation], timeout: 1)
    }
    
    func testFailsValidation() {
        let expecation = XCTestExpectation()
        let future = Promise(value: 5).futureResult
        future.validate({ (value) -> Bool in
            return value % 2 == 0
        }).catch({ (error) in
            XCTAssertEqual(error as? FutureError, FutureError.validationFailed)
            expecation.fulfill()
        })
        wait(for: [expecation], timeout: 1)
    }
    
    func testValidationThrows() {
        let expecation = XCTestExpectation()
        let future = Promise(value: 5).futureResult
        future.validate({ (value) -> Bool in
            if value % 2 != 0 {
                throw TestError.test
            }
            return true
        }).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expecation.fulfill()
        })
        wait(for: [expecation], timeout: 1)
    }
}
