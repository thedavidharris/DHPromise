//
//  Future+Validate.swift
//  DHPromise
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

extension Future {


    /// Validates the value of a successfully resolved Future, and rejects the chain if validation does not pass
    ///
    /// - Parameter validate: validation block to execute on returned value
    /// - Returns: validated Future object
    @discardableResult
    public func validate(_ validate: @escaping (Value) throws -> Bool) -> Future<Value> {
        return self.map({ (value)  in
            guard try validate(value) else {
                throw FutureError.validationFailed
            }
            return value
        })
    }
}
