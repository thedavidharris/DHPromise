//
//  FutureSpec+Finally.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Foundation
import Quick
import Nimble
import Futura

class FutureFinallySpec: QuickSpec {
    override func spec() {
        describe("Future+Finally") {
            it("should execute always block on successful future") {
                var sideEffectVariable: Int?
                let future = Promise(value: 4).futureResult

                waitUntil(action: { (done) in
                    future.then { sideEffectVariable = $0 }.always {
                        expect(sideEffectVariable) == 4
                        done()
                    }
                })
            }

            it("should execute always block on failed future") {
                var sideEffectError: Error?
                let future = Promise<Int>(error: TestError()).futureResult
                waitUntil(action: { (done) in
                    future.catch { sideEffectError = $0 }.always {
                        expect(sideEffectError).to(matchError(TestError()))
                        done()
                    }
                })
            }
        }
    }
}
