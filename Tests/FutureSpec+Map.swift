//
//  FutureSpec+Map.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Futura

class FutureMapSpec: QuickSpec {
    override func spec() {
        describe("Future+FlatMap") {
            it("should chain two successful futures using flatmap") {
                waitUntil(action: { (done) in
                    asyncFuture(from: .success(4)).flatMap({ (value) in
                        asyncFuture(from: .success(String(value)))
                    }).then({ (finalValue) in
                        expect(finalValue) == "4"
                        done()
                    })
                })
            }

            it("should return error of first future in chain") {
                waitUntil(action: { (done) in
                    asyncFuture(from: Result<Int>.failure(TestError())).flatMap({ (value) in
                        asyncFuture(from: .success(String(value)))
                    }).catch({ (error) in
                        expect(error).to(matchError(TestError()))
                        done()
                    })
                })
            }

            it("should return error of second future in chain") {
                waitUntil(action: { (done) in
                    asyncFuture(from: .success(4)).flatMap({ (value) in
                        asyncFuture(from: Result<String>.failure(TestError()))
                    }).catch({ (error) in
                        expect(error).to(matchError(TestError()))
                        done()
                    })
                })
            }

            it("should return error if flatmap closure throws") {
                waitUntil(action: { (done) in
                    asyncFuture(from: .success(4)).flatMap({ (value) in
                        try throwingFuture(successValue: 12, shouldThrow: true)
                    }).catch({ (error) in
                        expect(error).to(matchError(TestError()))
                        done()
                    })
                })
            }
        }

        describe("Future+Map") {
            it("should run the map closure on the future value") {
                waitUntil(action: { (done) in
                    asyncFuture(from: .success(4)).map({ (value) in
                        String(value)
                    }).then({ (finalValue) in
                        expect(finalValue) == "4"
                        done()
                    })
                })
            }

            it("should return error if Future has failed") {
                waitUntil(action: { (done) in
                    asyncFuture(from: Result<Int>.failure(TestError())).map({ (value) in
                        String(value)
                    }).catch({ (error) in
                        expect(error).to(matchError(TestError()))
                        done()
                    })
                })
            }

            it("should return error if map closure throws") {
                waitUntil(action: { (done) in
                    asyncFuture(from: .success(4)).map({ _ in
                        throw TestError()
                    }).catch({ (error) in
                        expect(error).to(matchError(TestError()))
                        done()
                    })
                })
            }
        }
    }
}
