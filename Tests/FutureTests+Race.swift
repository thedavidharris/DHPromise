//
//  FutureSpec+Race.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import XCTest
import Futura

class FutureRaceTests: XCTestCase {
    func testRaceLikeTypes() {
        let expectation = XCTestExpectation()
        let first = Promise<Int>()
        let second = Promise<Int>()
        let third = Promise<Int>()
        
        let futures: [Future<Int>] = [first.futureResult,
                                      second.futureResult,
                                      third.futureResult]
        
        Future.race(futures).then({ (value) in
            XCTAssertEqual(value, 2)
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            first.resolve(value: 1)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            second.resolve(value: 2)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            third.resolve(value: 3)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testRaceLikeTypesVariadic() {
        let expectation = XCTestExpectation()
        let first = Promise<Int>()
        let second = Promise<Int>()
        let third = Promise<Int>()
        
        Future.race(first.futureResult, second.futureResult, third.futureResult).then({ (value) in
            XCTAssertEqual(value, 2)
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            first.resolve(value: 1)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            second.resolve(value: 2)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            third.resolve(value: 3)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testRaceResolveFirstError() {
        let expectation = XCTestExpectation()
        let first = Promise<Int>()
        let second = Promise<Int>()
        let third = Promise<Int>()
        
        Future.race(first.futureResult, second.futureResult, third.futureResult).catch({ (error) in
            XCTAssertEqual(error as? TestError, TestError.test)
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            first.resolve(value: 1)
            expectation.fulfill()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            second.resolve(value: 2)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            third.reject(error: TestError.test)
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testEmptyRace() {
        let expectation = XCTestExpectation()
        Future<Void>.race([Future<Void>]()).catch({ (error) in
            XCTAssertEqual(error as? FutureError, FutureError.emptyRace)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func testFutureRaceUnlikeTypesRightSpot() {
        let expectation = XCTestExpectation()
        let first = Promise<Int>()
        let second = Promise<String>()
        
        race(first.futureResult, second.futureResult).then({ (either) in
            switch either {
            case .Right(let value):
                XCTAssertEqual(value, "Two")
            case .Left:
                XCTFail()
            }
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            first.resolve(value: 1)
            expectation.fulfill()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            second.resolve(value: "Two")
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testFutureRaceUnlikeTypesLeftSpot() {
        let expectation = XCTestExpectation()
        let first = Promise<Int>()
        let second = Promise<String>()
        
        race(first.futureResult, second.futureResult).then({ (either) in
            switch either {
            case .Right(let value):
                XCTAssertEqual(value, "Two")
            case .Left:
                XCTFail()
            }
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            second.resolve(value: "Two")
            expectation.fulfill()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            first.resolve(value: 1)
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testRaceThreeUnlike() {
        let expectation = XCTestExpectation()
        let first = Promise<Int>()
        let second = Promise<String>()
        let third = Promise<Bool>()
        
        race(first.futureResult, second.futureResult, third.futureResult).then({ (value) in
            XCTAssertEqual(value as? String, "Two")
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            first.resolve(value: 1)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            second.resolve(value: "Two")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            third.resolve(value: false)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
