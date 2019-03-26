//
//  FutureSpec+Do.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import XCTest
import Futura

class FutureDoTests: XCTestCase {
    func testDoSuccess() {
        let expecation = XCTestExpectation()
        var sideEffectVariable: Int?
        let future = Promise(value: 4).futureResult
        
        future.do({ sideEffectVariable = $0 * 2 }).then {
            XCTAssertEqual(sideEffectVariable, $0 * 2)
            expecation.fulfill()
        }
        wait(for: [expecation], timeout: 1)
    }
    
    func testDoFailure() {
        let expecation = XCTestExpectation()
        let future = Promise(value: 4).futureResult
        
        future.do({ _ in throw TestError.test }).catch {
            XCTAssertEqual($0 as? TestError, TestError.test)
            expecation.fulfill()
        }
        wait(for: [expecation], timeout: 1)
    }
}
