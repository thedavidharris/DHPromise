//
//  FutureSpec+Variadic.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import XCTest
import Futura

class FutureVariadicTests: XCTestCase {
    func testEmptyError() {
        let expectation = XCTestExpectation()
        Future<[Int]>.all([Future<Int>]()).then({ (value) in
            XCTAssertEqual(value, [])
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func testBothSucceed() {
        let expectation = XCTestExpectation()
        let first = Promise<Int>()
        let second = Promise<Int>()
        
        Future<[Int]>.all(first.futureResult, second.futureResult).then({ (value) in
            XCTAssertEqual(value, [4, 8])
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            first.resolve(value: 4)
            expectation.fulfill()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            second.resolve(value: 8)
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testErrorIfEitherFail() {
        let expectation = XCTestExpectation()
        let first = Promise<Int>()
        let second = Promise<Int>()
        
        Future<[Int]>.all(first.futureResult, second.futureResult).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            first.reject(error: TestError.test)
            expectation.fulfill()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            second.resolve(value: 8)
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testZipTwoUnlikeTypes() {
        let expectation = XCTestExpectation()
        let first = Promise(value: 4).futureResult
        let second = Promise(value: "Four").futureResult
        
        zip(first, second).then({ (int, string) in
            XCTAssertEqual(int, 4)
            XCTAssertEqual(string, "Four")
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func testZipError() {
        let expectation = XCTestExpectation()
        let first = Promise(value: 4).futureResult
        let second = Promise<String>(error: TestError.test).futureResult
        
        zip(first, second).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func testZipThreeUnlikeTypes() {
        let expectation = XCTestExpectation()
        let first = Promise(value: 4).futureResult
        let second = Promise(value: "Four").futureResult
        let third = Promise(value: true).futureResult
        
        zip(first, second, third).then({ (int, string, bool) in
            XCTAssertEqual(int, 4)
            XCTAssertEqual(string, "Four")
            XCTAssertEqual(bool, true)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func testZipThreeUnlikeTypesError() {
        let expectation = XCTestExpectation()
        let first = Promise(value: 4).futureResult
        let second = Promise<String>(error: TestError.test).futureResult
        let third = Promise(value: true).futureResult
        
        zip(first, second, third).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
}

