//
//  FutureSpec+Wrap.swift
//  Futura
//
//  Created by David Harris on 6/2/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import XCTest
import Futura

class FutureWrapTests: XCTestCase {
    func testWrapCompletionHandlerSuccess() {
        let expectation = XCTestExpectation()
        let future = Future<Int>.wrap(completion: {
            regularCompletion(result: .success(5), $0)
        })
        future.then { (value) in
            XCTAssertEqual(value, 5)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testWrapCompletionHandlerError() {
        let expectation = XCTestExpectation()
        let future = Future<Int>.wrap(completion: {
            regularCompletion(result: Result<Int>.failure(TestError.test), $0)
        })
        future.catch { (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testWrapResultCompletionHandler() {
        let expectation = XCTestExpectation()
        let future = Future<Int>.wrap(completion: {
            resultCompletion(result: .success(5), $0)
        })
        future.then { (value) in
            XCTAssertEqual(value, 5)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testWrapResultCompletionHandlerError() {
        let expectation = XCTestExpectation()
        let future = Future<Int>.wrap(completion: {
            resultCompletion(result: Result<Int>.failure(TestError.test), $0)
        })
        future.catch { (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}

func regularCompletion(result: Result<Int>, _ completion: (Int?, Error?) -> Void) {
    switch result {
    case .success(let value):
        completion(value, nil)
    case .failure(let error):
        completion(nil, error)
    }
}

func resultCompletion(result: Result<Int>, _ completion: (Result<Int>) -> Void) {
    completion(result)
}
