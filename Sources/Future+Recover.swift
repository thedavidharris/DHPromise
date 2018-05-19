//
//  Future+Recover.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Future {
    @discardableResult
    /// Recovers a failed Future object
    ///
    /// - Parameter recoverBlock: block to transform a failed Future's associated error to a new future
    /// - Returns: new Future object
    public func recover(_ recoverBlock: @escaping (Error) throws -> Future<Value>) -> Future<Value> {
        return Promise { fulfill, reject in
            self.then(fulfill).catch({ error in
                do {
                    try recoverBlock(error).then(fulfill).catch(reject)
                } catch (let error) {
                    reject(error)
                }
            })
        }.futureResult
    }
}
