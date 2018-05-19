//
//  FutureSpec+Variadic.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Futura

class FutureVariadicSpec: QuickSpec {
    override func spec() {
        it("should return empty array if called with empty input") {
            waitUntil(action: { (done) in
                Future<[Int]>.all([Future<Int>]()).then({ (value) in
                    expect(value) == []
                    done()
                })
            })
        }

        describe("resolving like-typed futures") {
            it("should return values of both if both succeed") {
                let first = Promise<Int>()
                let second = Promise<Int>()

                waitUntil(action: { (done) in
                    Future<[Int]>.all(first.futureResult, second.futureResult).then({ (value) in
                        expect(value) == [4, 8]
                    })

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        first.resolve(value: 4)
                        done()
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
                        second.resolve(value: 8)
                    }
                })
            }

            it("should return error if either fail") {
                let first = Promise<Int>()
                let second = Promise<Int>()

                waitUntil(action: { (done) in
                    Future<[Int]>.all(first.futureResult, second.futureResult).catch({ (error) in
                        expect(error).to(matchError(TestError()))
                    })

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        first.reject(error: TestError())
                        done()
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
                        second.resolve(value: 8)
                    }
                })
            }
        }

        describe("zipping two unlike futures") {
            it("should return values if both succeed") {
                let first = Promise(value: 4).futureResult
                let second = Promise(value: "Four").futureResult

                waitUntil(action: { (done) in
                    zip(first, second).then({ (int, string) in
                        expect(int) == 4
                        expect(string) == "Four"
                        done()
                    })
                })
            }

            it("should return error if one fails") {
                let first = Promise(value: 4).futureResult
                let second = Promise<String>(error: TestError()).futureResult

                waitUntil(action: { (done) in
                    zip(first, second).catch({ (error) in
                        expect(error).to(matchError(TestError()))
                        done()
                    })
                })
            }
        }

        describe("zipping three unlike futures") {
            it("should return values if all succeed") {
                let first = Promise(value: 4).futureResult
                let second = Promise(value: "Four").futureResult
                let third = Promise(value: true).futureResult

                waitUntil(action: { (done) in
                    zip(first, second, third).then({ (int, string, bool) in
                        expect(int) == 4
                        expect(string) == "Four"
                        expect(bool) == true
                        done()
                    })
                })
            }

            it("should return error if one fails") {
                let first = Promise(value: 4).futureResult
                let second = Promise<String>(error: TestError()).futureResult
                let third = Promise(value: true).futureResult

                waitUntil(action: { (done) in
                    zip(first, second, third).catch({ (error) in
                        expect(error).to(matchError(TestError()))
                        done()
                    })
                })
            }
        }
    }
}
