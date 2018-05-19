//
//  FutureSpec+Do.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Futura

class FutureDoSpec: QuickSpec {
    override func spec() {
        describe("Future+Do") {
            it("should inject side effects to a successful promise using do") {
                var sideEffectVariable: Int?
                let future = Promise(value: 4).futureResult

                waitUntil(action: { (done) in
                    future.do({ sideEffectVariable = $0 * 2 }).then {
                        expect(sideEffectVariable) == $0 * 2
                        done()
                    }
                })
            }

            it("should resolve Future with an error if side effect throws an error") {
                let future = Promise(value: 4).futureResult
                waitUntil(action: { (done) in
                    future.do({ _ in throw TestError() }).catch {
                        expect($0).to(matchError(TestError()))
                        done()
                    }
                })
            }
        }
    }
}

