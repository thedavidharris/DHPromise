//
//  Promise.swift
//  DHPromise
//
//  Created by David Harris on 02/10/17.
//  Copyright © 2017 thedavidharris. All rights reserved.
//

import Foundation

/// An enum representing the possible states of a promise
///
/// - resolved: The Promise has completed successfully with an associated value
/// - rejected: The Promise has completed unsuccessfully with an associated error
/// - pending: The Promise is in progress, and has not completed with either a value or an error
enum PromiseState {
    case resolved
    case rejected
    case pending
}

/// A representation of a Future with completion callbacks
class Promise<Value> {

    /// Current state of the Promise
    public var state: PromiseState {
        switch result {
        case .some(let resultValue):
            switch resultValue {
            case .success:
                return .resolved
            case .failure:
                return .rejected
            }
        case .none:
            return .pending
        }
    }

    /// Associated result type of the promise
    public var result: Result<Value>? {
        didSet {
            fireCompletionCallbacks()
        }
    }


    /// Convenience accessor for the associated value of the promise
    public var value: Value? {
        return result?.value
    }

    /// Convenience accessor for the associated value of the promise
    public var error: Error? {
        return result?.error
    }

    /// Callbacks to be executed upon successful completion of a promise
    private lazy var successCallbacks = [(Value) -> Void]()


    /// Callbacks to be executed on unsuccessful completion of a promise
    private lazy var errorCallbacks = [(Error) -> Void]()


    /// Initializer for the promise
    ///
    /// - Parameter work: Closure containing async work. Contains two internal parameters, a `resolve` closure and a `reject` closure to be executed depending on successful or unsuccessful completion of the promise
    public convenience init(_ work: @escaping (_ resolve: @escaping (Value) -> (), _ reject: @escaping (Error) -> ()) throws -> ()) {
        self.init()
        do {
            try work(self.resolve, self.reject)
        } catch let error {
            self.reject(with: error)
        }
    }

    /// Completes a promise by resolving with a value
    ///
    /// - Parameter value: value to complete the promise with
    public func resolve(with value: Value) {
        self.result = .success(value)
    }

    /// Completes a promise by rejecting with an error
    ///
    /// - Parameter error: error to reject the promise with
    public func reject(with error: Error) {
        self.result = .failure(error)
    }

    /// Execute a closure upon successful completion of the promise
    ///
    /// - Parameter callback: closure to execute upon completion of the promise
    /// - Returns: the existing promise object
    @discardableResult
    public func then(_ onFulfilled: @escaping (Value) -> Void) -> Promise<Value> {
        successCallbacks.append(callback)
        return self
    }

    /// Execute a closure upon unsuccessful completion of the promise
    ///
    /// - Parameter callback: closure to execute upon completion of the promise
    /// - Returns: the existing promise object
    @discardableResult
    public func onError(_ onRejected: @escaping (Error) -> Void) -> Promise<Value> {
        errorCallbacks.append(callback)
        return self
    }

    /// Fires stored completion callbacks once promise is completed
    private func fireCompletionCallbacks() {
        switch state {
        case .resolved:
            successCallbacks.forEach {
                result?.value.map($0)
            }
        case .rejected:
            errorCallbacks.forEach {
                result?.error.map($0)
            }
        case .pending:
            break
        }
    }
}
