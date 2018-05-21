//
//  Future.swift
//  Futura
//
//  Created by David Harris on 5/17/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

/// An enum representing the possible states of a promise
///
/// - resolved: The Future has completed successfully with an associated value
/// - rejected: The Future has completed unsuccessfully with an associated error
/// - pending: The Future is in progress, and has not completed with either a value or an error
public enum FutureState {
    case resolved
    case rejected
    case pending
}

/// Abstract Future type implemented by Future<T>
public protocol FutureType {
    /// This future's expected value type.
    associatedtype Expectation

    /// State of the FutureType
    var state: FutureState { get }

    /// Value of the resolved future, or nil if unresolved
    var value: Expectation? { get }


    /// Abstract thenable behavior
    ///
    /// - Parameters:
    ///   - queue: queue to execute callback on
    ///   - onFulfilled: callback to execute on successful execution
    /// - Returns: the FutureType object
    @discardableResult
    func then(on queue: DispatchQueue, _ onFulfilled: @escaping (Expectation) -> Void) -> Future<Expectation>
}

public class Future<Value>: FutureType {

    public typealias Expectation = Value

    /// Current state of the Promise
    public var state: FutureState {
        switch _result {
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

    /// Private underlying value of Promise.result for thread-safe access
    private var _result: Result<Value>?

    /// Result value of the promise
    public internal(set) var result: Result<Value>? {
        get {
            return lockQueue.sync {
                return self._result
            }
        }
        set {
            lockQueue.sync {
                _result = newValue
            }
            fireCompletionCallbacks()
        }
    }


    /// Convenience accessor for the associated value of the future
    public var value: Value? {
        return result?.value
    }

    /// Convenience accessor for the associated error of the future
    public var error: Error? {
        return result?.error
    }

    /// Callbacks attached to the future object
    lazy private var callbacks = [Callback<Value>]()

    /// Locked queue to allow for thread-safety within the Future object
    private let lockQueue = DispatchQueue(label: "future_lock_queue", qos: .userInitiated)


    /// Initializes the future with a Result object, completing it if the result is not nil
    ///
    /// - Parameter result: optional Result value to initialize the Future with
    init(result: Result<Value>? = nil) {
        self.result = result
    }

    /// Initializes a resolved Future with the provided value
    ///
    /// - Parameter value: value to resolve Future successfully with
    init(value: Value) {
        self.result = .success(value)
    }

    /// Intializes an unsuccessful Future with the provided error
    ///
    /// - Parameter error: error to resolve Future unsuccessfully in
    init(error: Error) {
        self.result = .failure(error)
    }

    /// Execute a closure upon successful completion of the future
    ///
    /// - Parameter callback: closure to execute upon completion of the promise
    /// - Returns: the existing promise object
    @discardableResult
    public func then(on queue: DispatchQueue = DispatchQueue.main, _ onFulfilled: @escaping (Value) -> Void) -> Future<Value> {
        addCallback(on: queue, onFulfilled: onFulfilled)
        return self
    }

    /// Execute a closure upon unsuccessful completion of the promise
    ///
    /// - Parameter callback: closure to execute upon completion of the promise
    /// - Returns: the existing promise object
    @discardableResult
    public func `catch`(on queue: DispatchQueue = DispatchQueue.main, _ onRejected: @escaping (Error) -> Void) -> Future<Value> {
        addCallback(on: queue, onRejected: onRejected)
        return self
    }

    /// Adds a success or error callback to be executed upon completion of the Future
    ///
    /// - Parameters:
    ///   - queue: DispachQueue for the call
    ///   - onFulfilled: success callback to add
    ///   - onRejected: error callback to add
    func addCallback(on queue: DispatchQueue, onFulfilled: ((Value) -> ())? = nil, onRejected: ((Error) -> ())? = nil) {
        lockQueue.async {
            let callback = Callback(onFulfilled: onFulfilled,
                                    onRejected: onRejected,
                                    queue: queue)
            self.callbacks.append(callback)
        }
        fireCompletionCallbacks()
    }

    /// Fires stored completion callbacks once promise is completed
    private func fireCompletionCallbacks() {
        lockQueue.async {
            switch self.state {
            case .resolved, .rejected:
                self.callbacks.forEach { callback in
                    self._result.map(callback.executeCallback)
                }
                self.callbacks.removeAll()
            case .pending:
                break
            }
        }
    }
}
