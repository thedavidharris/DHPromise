//
//  Future+Do.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Future {

    /// Injects an action into the Future sequence without affecting the callback chain, unless the side effect throws an error
    ///
    /// - Parameters:
    ///   - queue: queue to execute callback on
    ///   - action: side effect to execute
    /// - Returns: existing Future object
    @discardableResult
    public func `do`(on queue: DispatchQueue = DispatchQueue.main, _ action: @escaping (Value) throws -> Void) -> Future<Value> {
        return self.flatMap({ (value) in
            return Promise({ (fulfill, reject) in
                do {
                    try action(value)
                    fulfill(value)
                } catch {
                    reject(error)
                }
            }).futureResult
        })
    }
}
