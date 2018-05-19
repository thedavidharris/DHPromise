//
//  Future+Finally.swift
//  DHPromise
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Future {
    /// Execute a closure on completion of promise in both fulfilled and error states
    ///
    /// - Parameter onFinally: closure to execute upon completion
    /// - Returns: the existing Future object
    @discardableResult
    public func finally(_ onFinally: @escaping () -> Void) -> Future<Value> {
        return then({ _ in
            onFinally()
        }).catch({ _ in
            onFinally()
        })
    }
}