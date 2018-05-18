//
//  Future+Time.swift
//  DHPromise
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

extension Future {
    @discardableResult
    public func delay(_ timeInterval: TimeInterval) -> Future<Value> {
        return Promise<Void> { (fulfill, reject) in
            DispatchQueue.global().asyncAfter(deadline: .now() + timeInterval, execute: {
                    fulfill(())
                })
            }.futureResult.flatMap { _ in self }
    }

    // TODO: This timeout is not quite accurate, needs work with the queues
    @discardableResult
    public func timeout(_ timeInterval: TimeInterval) -> Future<Value> {
        return Promise<Value> { (fulfill, reject) in
            DispatchQueue.global().asyncAfter(deadline: .now() + timeInterval, execute: {
                reject(Problem.timeout)
            })

            self.then(fulfill).catch(reject)
            }.futureResult
    }
}
