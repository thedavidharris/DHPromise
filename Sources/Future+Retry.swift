//
//  Future+Retry.swift
//  DHPromise
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Future {
    
    @discardableResult
    public static func retry<Value>(attempts: Int, delay delayTime: TimeInterval, retryBody: @escaping () -> Future<Value>) -> Future<Value> {

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
