//
//  FutureSpec+Recover.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Futura

class FutureRecoverSpec: QuickSpec {
    override func spec() {
        it("should recover from a failed state") {
            let future = Promise<Int>(error: TestError()).futureResult

            waitUntil(action: { (done) in
                future.recover({ _ -> Future<Int> in
                    Promise(value: 4).futureResult
                }).then({ (value) in
                    expect(value) == 4
                    done()
                })
            })
        }

        it("should fail to recover if recover block throws") {
            let future = Promise<Int>(error: TestError()).futureResult

            waitUntil(action: { (done) in
                future.recover({ _ -> Future<Int> in
                    try throwingFuture(successValue: 12, shouldThrow: true)
                }).catch({ (error) in
                    expect(error).to(matchError(TestError()))
                    done()
                })
            })
        }
    }
}
