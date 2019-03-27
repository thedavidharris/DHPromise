//
//  Promise+Void.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

extension Promise where Value == Void {
    /// Convenience function to create a completed Promise<Void>
    ///
    /// - Returns: A completed promise
    public static func done() -> Promise<Value> {
        return Promise(value: ())
    }

    /// Convenience function to resolve a Promise<Void>
    public func resolve() {
        futureResult.result = .success(())
    }
}
