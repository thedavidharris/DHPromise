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
public enum PromiseState {
    case resolved
    case rejected
    case pending
}

/// A representation of a Future with completion callbacks
public class Promise<Value> {

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

    public convenience init(value: Value) {
        self.init()
        self.result = .success(value)
    }

    public convenience init(error: Error) {
        self.init()
        self.result = .failure(error)
    }


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
        successCallbacks.append(onFulfilled)
        return self
    }

    /// Execute a closure upon unsuccessful completion of the promise
    ///
    /// - Parameter callback: closure to execute upon completion of the promise
    /// - Returns: the existing promise object
    @discardableResult
    public func onError(_ onRejected: @escaping (Error) -> Void) -> Promise<Value> {
        errorCallbacks.append(onRejected)
        return self
    }

    /// Execute a closure on completion of promise in both fulfilled and error states
    ///
    /// - Parameter onFinally: closure to execute upon completion
    /// - Returns: the existing promise object
    @discardableResult
    public func finally(_ onFinally: @escaping () -> ()) -> Promise<Value> {
        return then({ _ in
            onFinally()
        }).onError({ _ in
            onFinally()
        })
    }

    /// Chains promise objects together
    ///
    /// - Parameter onFulfilled: closure to execute upon successful completion
    /// - Returns: existing promise object
    @discardableResult
    public func flatMap<NewValue>(_ onFulfilled: @escaping (Value) -> Promise<NewValue>) -> Promise<NewValue> {
        return Promise<NewValue> { (fullfill, reject) in
            self.successCallbacks.append({ (value) in
                onFulfilled(value).then({ (newValue) in
                    fullfill(newValue)
                }).onError({ (error) in
                    reject(error)
                })
            })

            self.errorCallbacks.append({ (error) in
                reject(error)
            })
        }
    }

    /// Maps the underlying type in the Promise object
    ///
    /// - Parameter onFulfilled: closure to execute upon successful completion
    /// - Returns: the existing promise object
    @discardableResult
    public func map<NewValue>(_ onFulfilled: @escaping (Value) -> NewValue) -> Promise<NewValue> {
        return flatMap { (value) in
            return Promise<NewValue>(value: onFulfilled(value))
        }
    }

    /// Fires stored completion callbacks once promise is completed
    private func fireCompletionCallbacks() {
        switch state {
        case .resolved:
            successCallbacks.forEach {
                result?.value.map($0)
            }
            removeAllCallbacks()
        case .rejected:
            errorCallbacks.forEach {
                result?.error.map($0)
            }
            removeAllCallbacks()
        case .pending:
            break
        }
    }

    private func removeAllCallbacks() {
        successCallbacks.removeAll()
        errorCallbacks.removeAll()
    }
}

/// Resolve multiple promises of the same type into a single promise returning an array of the fulfilled values
///
/// - Parameter promises: an array of promises of the same type
/// - Returns: a single promise combining the resolved values of `promises`
public func all<Value>(_ promises: [Promise<Value>]) -> Promise<[Value]> {
    return Promise<[Value]>{ (fullfill, reject) in
        if promises.isEmpty {
            fullfill([])
        }
        promises.forEach({ (promise) in
            promise.then({ _ in
                if promises.containsOnly(where: { $0.state == .resolved }) {
                    // Switch to compactMap in Swift 4.1
                    fullfill(promises.flatMap({ $0.value }))
                }
            }).onError({ (error) in
                reject(error)
            })
        })
    }
}

/// Variadic implemention of resolving all promises
///
/// - Parameter promises: an array of promises of the same type
/// - Returns: a single promise combining the resolved values of `promises`
public func all<Value>(_ promises: Promise<Value>...) -> Promise<[Value]> {
    return all(promises)
}

/// Returns the first promise resolved in an array of promises
///
/// - Parameter promises: an array of promises of the same type
/// - Returns: the first promises to resolve
public func race<Value>(_ promises: [Promise<Value>]) -> Promise<Value> {
    return Promise<Value> { (fulfill, reject) in
        if promises.isEmpty {
            fatalError("Cannot call `race` on an empty array")
        }
        promises.forEach {
            $0.then(fulfill).onError(reject)
        }
    }
}

// Can remove on inclusion into Swift STL
extension Sequence {
    public func containsOnly(where predicate: (Element) throws -> Bool) rethrows -> Bool {
    return try !contains { try !predicate($0) }
    }
}
