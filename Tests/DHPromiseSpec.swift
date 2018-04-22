//
//  DHPromiseSpec.swift
//  DHPromise
//
//  Created by David Harris on 04/10/16.
//  Copyright © 2017 thedavidharris. All rights reserved.
//

import Quick
import Nimble
@testable import DHPromise

class DHPromiseSpec: QuickSpec {

    override func spec() {

        describe("When making a successful promise call") {
            it("should return a success") {
                let promise = asyncSquareRoot(input: 4)
                expect(promise.value).toEventually(equal(2))
            }
        }

        describe("When making a promise call that returns an error") {
            it("should return a success") {
                let promise = asyncSquareRoot(input: -4)
                expect(promise.error).toEventually(matchError(SquareRootError.negativeInput))
            }
        }
    }
}

enum SquareRootError: Error {
    case negativeInput
}

func asyncSquareRoot(input: Double) -> Promise<Double> {
    return Promise { (resolve, reject) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            if input < 0 {
                return reject(SquareRootError.negativeInput)
            }
            return resolve(sqrt(input))
        }
    }
}
