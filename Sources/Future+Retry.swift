//
//  Future+Retry.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

extension Future {

    /// Catches a failed Future and executes a retry block
    ///
    /// - Parameters:
    ///   - attempts: number of attempts to retry the failed Future
    ///   - delayTime: amount of time to delay between retries
    ///   - retryBody: closure to execute to retry
    /// - Returns: existing Future object
    @discardableResult
    public func retry<Value>(attempts: Int, delay delayTime: TimeInterval = 0, retryBody: @escaping () -> Future<Value>) -> Future<Value> {

        var attemptsLeft = attempts

        func attempt() -> Future<Value> {
            return retryBody().recover { error in
                guard attemptsLeft > 0 else {
                    throw error
                }
                attemptsLeft -= 1
                return attempt().delay(delayTime)
            }
        }

        return attempt()
    }
}
