//
//  FutureSpec+Collection.swift
//  Futura
//
//  Created by David Harris on 5/20/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import XCTest
import Futura


class FutureCollectionSpec: XCTestCase {
    func testResolveEmptyCollection() {
        let expectation = XCTestExpectation()
        
        [Future<Int>]().flatten().then({ (value) in
            XCTAssertEqual(value, [])
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testResolveAllPromisesInCollection() {
        let expectation = XCTestExpectation()
        
        let first = Promise<Int>()
        let second = Promise<Int>()
        
        let collection = [first.futureResult, second.futureResult]
        
        collection.flatten().then({ (values) in
            XCTAssertEqual(values, [4, 8])
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
    
    func testError() {
        let expectation = XCTestExpectation()
        
        let first = Promise<Int>()
        let second = Promise<Int>()
        
        let collection = [first.futureResult, second.futureResult]
        
        collection.flatten().catch({ (error) in
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
    
    func testFirstResolved() {
        
        let expectation = XCTestExpectation()
        let first = Promise<Int>()
        let second = Promise<Int>()
        
        let collection = [first.futureResult, second.futureResult]
        
        collection.firstCompleted().then({ (value) in
            XCTAssertEqual(value, 8)
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
    
}
