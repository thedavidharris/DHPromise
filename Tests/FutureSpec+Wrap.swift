//
//  FutureSpec+Wrap.swift
//  Futura
//
//  Created by David Harris on 6/2/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Futura

class FutureWrapSpec: QuickSpec {
    override func spec() {
        it("should wrap Cocoa style completion handlers that succeed") {
            let future = Future<Int>.wrap(completion: {
                regularCompletion(result: .success(5), $0)
            })
            expect(future.value).toEventually(equal(5))
        }

        it("should wrap Cocoa style completion handlers that fail") {
            let future = Future<Int>.wrap(completion: {
                regularCompletion(result: Result<Int>.failure(TestError()), $0)
            })
            expect(future.error).toEventually(matchError(TestError()))
        }

        it("should wrap ResultType completion handlers that succeed") {
            let future = Future<Int>.wrap(completion: {
                resultCompletion(result: .success(5), $0)
            })
            expect(future.value).toEventually(equal(5))
        }

        it("should wrap Cocoa style completion handlers that fail") {
            let future = Future<Int>.wrap(completion: {
                resultCompletion(result: Result<Int>.failure(TestError()), $0)
            })
            expect(future.error).toEventually(matchError(TestError()))
        }
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
