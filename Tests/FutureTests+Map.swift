//
//  FutureSpec+Map.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import XCTest
import Futura

class FutureMapTests: XCTestCase {
    func testMapTwoSuccesses() {
        let expectation = XCTestExpectation()
            asyncFuture(from: .success(4)).flatMap({ (value) in
                asyncFuture(from: .success(String(value)))
            }).then({ (finalValue) in
                XCTAssertEqual(finalValue, "4")
                expectation.fulfill()
            })
    }
    
    func testMapFirstError() {
        let expecation = XCTestExpectation()
        asyncFuture(from: Result<Int, Error>.failure(TestError.test)).flatMap({ (value) in
            asyncFuture(from: .success(String(value)))
        }).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expecation.fulfill()
        })
        wait(for: [expecation], timeout: 1)
    }
    
    func testMapSecondError() {
        let expecation = XCTestExpectation()
        asyncFuture(from: .success(4)).flatMap({ (value) in
            asyncFuture(from: Result<String, Error>.failure(TestError.test))
        }).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expecation.fulfill()
        })
        wait(for: [expecation], timeout: 1)
    }
    
    func testFlatMapThrowsInClosure() {
        let expecation = XCTestExpectation()
        asyncFuture(from: .success(4)).flatMap({ (value) in
            try throwingFuture(successValue: 12, shouldThrow: true)
        }).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expecation.fulfill()
        })
        wait(for: [expecation], timeout: 1)
    }
    
    func testMapClosure() {
        let expecation = XCTestExpectation()
        asyncFuture(from: .success(4)).map({ (value) in
            String(value)
        }).then({ (finalValue) in
            XCTAssertEqual(finalValue, "4")
            expecation.fulfill()
        })
        wait(for: [expecation], timeout: 1)
    }
    
    func testMapFailedFuture() {
        let expecation = XCTestExpectation()
        asyncFuture(from: Result<Int, Error>.failure(TestError.test)).map({ (value) in
            String(value)
        }).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expecation.fulfill()
        })
        wait(for: [expecation], timeout: 1)
    }
    
    func testMapClosureThrows() {
        let expecation = XCTestExpectation()
        asyncFuture(from: .success(4)).map({ _ in
            throw TestError.test
        }).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expecation.fulfill()
        })
        wait(for: [expecation], timeout: 1)
    }
}
