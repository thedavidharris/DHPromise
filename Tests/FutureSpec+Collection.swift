//
//  FutureSpec+Collection.swift
//  Futura
//
//  Created by David Harris on 5/20/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Futura

class FutureCollectionSpec: QuickSpec {
    override func spec() {
        describe("flatten") {
            it("should resolve to empty array if called on empty collection") {
                waitUntil(action: { (done) in
                    [Future<Int>]().flatten().then({ (value) in
                        expect(value) == []
                        done()
                    })
                })
            }

            it("should resolve all promises in the collection") {
                let first = Promise<Int>()
                let second = Promise<Int>()

                let collection = [first.futureResult, second.futureResult]

                waitUntil(action: { (done) in
                    collection.flatten().then({ (values) in
                        expect(values) == [4, 8]
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

            it("should error if any future resolves to an error") {
                let first = Promise<Int>()
                let second = Promise<Int>()

                let collection = [first.futureResult, second.futureResult]

                waitUntil(action: { (done) in
                    collection.flatten().catch({ (error) in
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

        describe("first resolved") {
            it("should return first resolved promise") {
                let first = Promise<Int>()
                let second = Promise<Int>()

                let collection = [first.futureResult, second.futureResult]

                waitUntil(action: { (done) in
                    collection.firstCompleted().then({ (value) in
                        expect(value) == 8
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
        }
    }
}
