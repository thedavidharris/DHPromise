//
//  Callback.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

/// Object representing a piece of work to be executed upon completion of a Future
struct Callback<Value> {

    /// Work to execute on successful completion
    let onFulfilled: ((Value) -> Void)?

    /// Work to exectute on unsuccessful completion
    let onRejected: ((Error) -> Void)?

    /// Queue to execute work on
    let queue: DispatchQueue

    /// Run callback work for a given resolved value
    ///
    /// - Parameter result: resolved `Result` value to execute callback work with
    func executeCallback(_ result: Result<Value, Error>) {
        switch result {
        case .success(let value):
            queue.async {
                self.onFulfilled?(value)
            }
        case .failure(let error):
            queue.async {
                self.onRejected?(error)
            }
        }
    }
}
