//
//  FutureSpec+Validate.swift
//  DHPromise
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Quick
import Nimble
import DHPromise

class FutureValidateSpec: QuickSpec {
    override func spec() {
        it("should succeed future if it passes validation") {
            let future = Promise(value: 4).futureResult

            waitUntil(action: { (done) in
                future.validate({ (value) -> Bool in
                    return value % 2 == 0
                }).then({ (value) in
                    expect(value) == 4
                    done()
                })
            })
        }

        it("should fail future if it fails validation") {
            let future = Promise(value: 5).futureResult

            waitUntil(action: { (done) in
                future.validate({ (value) -> Bool in
                    return value % 2 == 0
                }).catch({ (error) in
                    expect(error).to(matchError(FutureError.validationFailed))
                    done()
                })
            })
        }

        it("should fail future if validation throws an error") {
            let future = Promise(value: 5).futureResult

            waitUntil(action: { (done) in
                future.validate({ (value) -> Bool in
                    if value % 2 != 0 {
                        throw TestError()
                    }
                    return true
                }).catch({ (error) in
                    expect(error).to(matchError(TestError()))
                    done()
                })
            })
        }
    }
}
