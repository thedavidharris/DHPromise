//
//  Future+Do.swift
//  DHPromise
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Future {
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
