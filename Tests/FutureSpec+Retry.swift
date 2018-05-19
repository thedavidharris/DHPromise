//
//  FutureSpec+Retry.swift
//  DHPromise
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Quick
import Nimble
import DHPromise

class FutureRetrySpec: QuickSpec {
    override func spec() {
        it("should retry a failed future") {
            let future = Promise<Int>(error: TestError()).futureResult

            waitUntil(action: { (done) in
                var attemptsLeft = 3
                future.retry(attempts: 3, retryBody: { () -> Future<Int> in 
                    attemptsLeft -= 1
                    if attemptsLeft == 1 {
                        return Promise(value: 4).futureResult
                    } else {
                        return Promise<Int>(error: TestError()).futureResult
                    }
                }).then({ (value) in
                    expect(value) == 4
                    done()
                })
            })
        }

        it("should fail a future after all retry attempts are used") {
            let future = Promise<Int>(error: TestError()).futureResult

            waitUntil(action: { (done) in
                future.retry(attempts: 3, retryBody: { () -> Future<Int> in
                    Promise<Int>(error: TestError()).futureResult
                }).catch({ (error) in
                    expect(error).to(matchError(TestError()))
                    done()
                })
            })
        }
    }
}
