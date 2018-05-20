//
//  FutureSpec+Init.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Futura

class FutureInitSpec: QuickSpec {
    override func spec() {
        describe("working with resolved futures") {
            it("should complete futures when initialized with a completed promise") {
                let goodFuture = Promise<Int>({ (fulfill, reject) in
                    fulfill(4)
                }).futureResult
                expect(goodFuture.value).toEventually(equal(4))

                let badFuture = Promise<Int>({ (fulfill, reject) in
                    reject(TestError())
                }).futureResult
                expect(badFuture.error).toEventually(matchError(TestError()))

                let successfulFuture = Promise(value: 4).futureResult
                expect(successfulFuture.value) == 4

                let failedFuture = Promise<Int>(error: TestError()).futureResult
                expect(failedFuture.error).to(matchError(TestError()))
            }

            it("should execute callbacks on resolved futures") {
                let successfulFuture = Promise(value: 4).futureResult
                waitUntil(action: { (done) in
                    successfulFuture.then {
                        expect($0) == 4
                        done()
                    }
                })

                let failedFuture = Promise<Int>(error: TestError()).futureResult
                waitUntil(action: { (done) in
                    failedFuture.catch {
                        expect($0).to(matchError(TestError()))
                        done()
                    }
                })
            }
        }
    }
}
