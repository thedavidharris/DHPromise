//
//  FutureSpec+Finally.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import XCTest
import Futura

class FutureFinallyTests: XCTestCase {
    func testAlwaysOnSuccess() {
        let expecation = XCTestExpectation()
        
        var sideEffectVariable: Int?
        let future = Promise(value: 4).futureResult
        
        future.then { sideEffectVariable = $0 }.always {
            XCTAssertEqual(sideEffectVariable, 4)
            expecation.fulfill()
        }
        
        wait(for: [expecation], timeout: 1)
    }
    
    func testAlwaysOnFailure() {
        let expecation = XCTestExpectation()
        var sideEffectError: Error?
        let future = Promise<Int>(error: TestError.test).futureResult
        future.catch { sideEffectError = $0 }.always {
            XCTAssertEqual(sideEffectError as? TestError, TestError.test)
            expecation.fulfill()
        }
        
        wait(for: [expecation], timeout: 1)
    }
}
