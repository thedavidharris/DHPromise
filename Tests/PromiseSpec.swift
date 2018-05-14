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
            it("should return the error") {
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

        describe("initializing an already fulfilled promise") {
            it("should resolve successfully when created with fulfilled value") {
                let promise = Promise(value: 4)
                expect(promise.value) == 4
            }

            it("should reject successfully when initialized with an error") {
                let promise = Promise<Any>(error: Problem.testError)
                expect(promise.error).to(matchError(Problem.testError))
            }
        }

        describe("When making chaining two successful promise calls") {
            it("should return a success") {
                let promise = asyncSquareRoot(input: 16).flatMap(asyncSquareRoot)
                expect(promise.value).toEventually(equal(2), timeout: 4)
            }

            it("should execute resolve closures for a successful promise") {
                waitUntil(timeout: 4, action: { (done) in
                    asyncSquareRoot(input: 16).flatMap({ (value) in
                        asyncSquareRoot(input: value)
                    }).then({ (finalValue) in
                        expect(finalValue) == 2
                        done()
                    })
                })
            }
        }

        describe("When making chaining two unsuccessful promise calls") {
            it("should return the firt error if the first promise errors") {
                let promise = asyncSquareRoot(input: -4).flatMap(asyncSquareRoot)
                expect(promise.error).toEventually(matchError(SquareRootError.negativeInput))
            }

            it("should return second error if second promise fails") {
                let firstPromise = asyncSquareRoot(input: 4)
                let secondPromise = asyncBasicPromise(from: Result<String>.failure(Problem.testError))
                let chained = firstPromise.flatMap { _ in secondPromise }
                expect(chained.error).toEventually(matchError(Problem.testError), timeout: 5)
            }
        }

        describe("mapping a promise call") {
            it("should map the promise result in success") {
                let chained = asyncSquareRoot(input: 4).map({ String($0) })
                expect(chained.value).toEventually(equal("2.0"))
            }

            it("should propogate the error result through the map") {
                let chained = asyncSquareRoot(input: -4).map({ String($0) })
                expect(chained.error).toEventually(matchError(SquareRootError.negativeInput))
            }
        }

        describe("when adding a finally call to a promise") {
            it("should trigger block when promise fulfills") {
                var result = false
                asyncSquareRoot(input: 4).finally {
                    result = true
                }
                expect(result).toEventually(beTrue())
            }

            it("should trigger block when promise fails") {
                var result = false
                asyncSquareRoot(input: -4).finally {
                    result = true
                }
                expect(result).toEventually(beTrue())
            }
        }

        describe("combining like promises") {
            it("should return the results of both when both succeed") {
                let firstPromise = asyncSquareRoot(input: 4)
                let secondPromise = slowerAyncSquareRoot(input: 16)
                let combined = DHPromise.all(firstPromise, secondPromise)
                expect(combined.value).toEventually(equal([2,4]))
            }
        }

        describe("timeout") {
            it("should reject promise if it takes longer than the timeout") {
                waitUntil(timeout: 1, action: { (done) in
                    slowerAyncSquareRoot(input: 4).timeout(0.49).onError({
                        expect($0).to(matchError(DHPromise.Problem.timeout))
                        done()
                    })
                })
            }

            it("should resolve promise if it resolves within timeout") {
                waitUntil(timeout: 1, action: { (done) in
                    slowerAyncSquareRoot(input: 4).timeout(0.6).then({
                        expect($0) == 2
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
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            if input < 0 {
                return reject(SquareRootError.negativeInput)
            }
            return resolve(sqrt(input))
        }
    }
}

func slowerAyncSquareRoot(input: Double) -> Promise<Double> {
    return Promise { (resolve, reject) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            if input < 0 {
                return reject(SquareRootError.negativeInput)
            }
            return resolve(sqrt(input))
        }
    }
}

func asyncBasicPromise<T>(from result: Result<T>) -> Promise<T> {
    return Promise({ (resolve, reject) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            switch result {
            case .success(let value):
                return resolve(value)
            case .failure(let error):
                return reject(error)
            }
        }
    })
}

enum Problem: Error {
    case testError
}
