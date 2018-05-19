//
//  FutureSpec+Race.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Futura

class FutureRaceSpec: QuickSpec {
    override func spec() {
        describe("racing like-typed futures") {
            it("should return value of first resolving future") {
                let first = Promise<Int>()
                let second = Promise<Int>()
                let third = Promise<Int>()

                let futures: [Future<Int>] = [first.futureResult,
                                              second.futureResult,
                                              third.futureResult]

                waitUntil(action: { (done) in
                    Future.race(futures).then({ (value) in
                        expect(value) == 2
                    })

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                        first.resolve(value: 1)
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        second.resolve(value: 2)
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                        third.resolve(value: 3)
                        done()
                    }
                })
            }

            it("should return value of first resolving future (variadic copy of above") {
                let first = Promise<Int>()
                let second = Promise<Int>()
                let third = Promise<Int>()

                waitUntil(action: { (done) in
                    Future.race(first.futureResult, second.futureResult, third.futureResult).then({ (value) in
                        expect(value) == 2
                    })

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                        first.resolve(value: 1)
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        second.resolve(value: 2)
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                        third.resolve(value: 3)
                        done()
                    }
                })
            }

            it("should return error of first resolving future") {
                let first = Promise<Int>()
                let second = Promise<Int>()
                let third = Promise<Int>()

                let futures: [Future<Int>] = [first.futureResult,
                                              second.futureResult,
                                              third.futureResult]

                waitUntil(action: { (done) in
                    Future.race(futures).catch({ (error) in
                        expect(error).to(matchError(TestError()))
                    })

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                        first.resolve(value: 1)
                        done()
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                        second.resolve(value: 2)
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        third.reject(error: TestError())
                    }
                })
            }

            it("should return an error if called with empty future objects") {
                waitUntil(action: { (done) in
                    Future<Void>.race([Future<Void>]()).catch({ (error) in
                        expect(error).to(matchError(FutureError.emptyRace))
                        done()
                    })
                })
            }
        }

        describe("racing two unlike-type promises, using the Either enum") {
            it("should return value of first resolving future in the right spot") {
                let first = Promise<Int>()
                let second = Promise<String>()

                waitUntil(action: { (done) in
                    race(first.futureResult, second.futureResult).then({ (either) in
                        switch either {
                        case .Right(let value):
                            expect(value) == "Two"
                        case .Left:
                            fail()
                        }
                    })

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                        first.resolve(value: 1)
                        done()
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        second.resolve(value: "Two")
                    }
                })
            }

            it("should return value of first resolving future in the left spot") {
                let first = Promise<Int>()
                let second = Promise<String>()

                waitUntil(action: { (done) in
                    race(first.futureResult, second.futureResult).then({ (either) in
                        switch either {
                        case .Right:
                            fail()
                        case .Left(let value):
                            expect(value) == 1
                        }
                    })

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        first.resolve(value: 1)
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                        second.resolve(value: "Two")
                        done()
                    }
                })
            }

            it("should return error of first resolving future") {
                let first = Promise<Int>()
                let second = Promise<String>()

                waitUntil(action: { (done) in
                    race(first.futureResult, second.futureResult).catch({ (error) in
                        expect(error).to(matchError(TestError()))
                    })

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        first.reject(error: TestError())
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                        second.resolve(value: "Two")
                        done()
                    }
                })
            }
        }

        describe("racing three unlike-typed futures") {
            it("should return value of first resolving future") {
                let first = Promise<Int>()
                let second = Promise<String>()
                let third = Promise<Bool>()

                waitUntil(action: { (done) in
                    race(first.futureResult, second.futureResult, third.futureResult).then({ (value) in
                        expect(value as? String) == "Two"
                    })

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                        first.resolve(value: 1)
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        second.resolve(value: "Two")
                    }

                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                        third.resolve(value: false)
                        done()
                    }
                })
            }

        }
    }
}
