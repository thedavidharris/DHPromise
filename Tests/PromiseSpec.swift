//
//  PromiseSpec.swift
//  DHPromise
//
//  Created by David Harris on 04/10/16.
//  Copyright © 2017 thedavidharris. All rights reserved.
//

import Quick
import Nimble
@testable import DHPromise

class PromiseSpec: QuickSpec {

    override func spec() {

        describe("When making a successful promise call") {
            it("should return a success") {
                let promise = asyncSquareRoot(input: 4)
                expect(promise.value).toEventually(equal(2))
            }

            it("should execute resolve closures for a successful promise") {
                waitUntil(action: { (done) in
                    asyncSquareRoot(input: 4).then({ (value) in
                        expect(value) == 2
                        done()
                    })
                })
            }
        }

        describe("When making a promise call that returns an error") {
            it("should return a success") {
                let promise = asyncSquareRoot(input: -4)
                expect(promise.error).toEventually(matchError(SquareRootError.negativeInput))
            }

            it("should execute error closures for an unsuccessful promise") {
                waitUntil(action: { (done) in
                    asyncSquareRoot(input: -2).onError({ (error) in
                        expect(error).to(matchError(SquareRootError.negativeInput))
                        done()
                    })
                })
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
