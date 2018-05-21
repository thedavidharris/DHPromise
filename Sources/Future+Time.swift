//
//  Future+Time.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

extension Future {

    /// Delays the Future for a defined amount of time
    ///
    /// - Parameter timeInterval: time to delay Future callbaks
    /// - Returns: existing Future object
    @discardableResult
    public func delay(_ timeInterval: TimeInterval) -> Future<Value> {
        return Promise<Void> { (fulfill, reject) in
            DispatchQueue.global().asyncAfter(deadline: .now() + timeInterval, execute: {
                    fulfill(())
                })
            }.futureResult.flatMap { _ in self }
    }

    @discardableResult
    // TODO: This timeout is not quite accurate, needs work with the queues
    /// Adds a timeout that a Future must resolve by, otherwise fail the Future
    ///
    /// - Parameter timeInterval: amount of time before Timeout error is thrown
    /// - Returns: existing Future object
    public func timeout(_ timeInterval: TimeInterval) -> Future<Value> {
        return Promise<Value> { (fulfill, reject) in
            DispatchQueue.global().asyncAfter(deadline: .now() + timeInterval, execute: {
                reject(FutureError.timeout)
            })

            self.then(fulfill).catch(reject)
            }.futureResult
    }
}
