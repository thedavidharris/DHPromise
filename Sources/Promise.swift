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

struct Callback<Value> {
    let onFulfilled: ((Value) -> Void)?
    let onRejected: ((Error) -> Void)?
    let queue: DispatchQueue

    func executeCallback(_ result: Result<Value>) {
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

/// A representation of a Future with completion callbacks
public class Promise<Value> {

    /// Current state of the Promise
    public var state: PromiseState {
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

    // TODO: this may need some added thread-safety
    /// Associated result type of the promise
    private var _result: Result<Value>?

    private var result: Result<Value>? {
        get {
           return promiseQueue.sync {
                return self._result
            }
        }
        set {
            promiseQueue.sync {
                _result = newValue
            }
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

    lazy var callbacks = [Callback<Value>]()

    /// Locked queue to allow for thread-safety within the promise object
    private let promiseQueue = DispatchQueue(label: "promise_queue", qos: .userInitiated)

    public init(value: Value) {
        self.result = .success(value)
    }

    public init(error: Error) {
        self.result = .failure(error)
    }


    /// Initializer for the promise
    ///
    /// - Parameter work: Closure containing async work. Contains two internal parameters, a `resolve` closure and a `reject` closure to be executed depending on successful or unsuccessful completion of the promise
    public init(_ work: @escaping (_ resolve: @escaping (Value) -> (), _ reject: @escaping (Error) -> ()) throws -> ()) {
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
    public func then(on queue: DispatchQueue = DispatchQueue.main, _ onFulfilled: @escaping (Value) -> Void) -> Promise<Value> {
        addCallbacks(on: queue, onFulfilled: onFulfilled)
        return self
    }

    /// Execute a closure upon unsuccessful completion of the promise
    ///
    /// - Parameter callback: closure to execute upon completion of the promise
    /// - Returns: the existing promise object
    @discardableResult
    public func onError(on queue: DispatchQueue = DispatchQueue.main, _ onRejected: @escaping (Error) -> Void) -> Promise<Value> {
        addCallbacks(on: queue, onRejected: onRejected)
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
    public func flatMap<NewValue>(on queue: DispatchQueue = DispatchQueue.main, _ onFulfilled: @escaping (Value) -> Promise<NewValue>) -> Promise<NewValue> {
        return Promise<NewValue> { (fullfill, reject) in
            self.addCallbacks(
                on: queue,
                onFulfilled: { (value) in
                    onFulfilled(value).then({ (newValue) in
                        fullfill(newValue)
                    }).onError({ (error) in
                        reject(error)
                    })
            }, onRejected: { (error) in
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

    private func addCallbacks(on queue: DispatchQueue, onFulfilled: ((Value) -> ())? = nil, onRejected: ((Error) -> ())? = nil) {
        promiseQueue.async {
            let callback = Callback.init(onFulfilled: onFulfilled,
                                         onRejected: onRejected,
                                         queue: queue)
            self.callbacks.append(callback)
        }
        fireCompletionCallbacks()
    }

    /// Fires stored completion callbacks once promise is completed
    private func fireCompletionCallbacks() {
        promiseQueue.async {
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


/// Namespace for Promise functions
public enum DHPromise {

    /// Resolve multiple promises of the same type into a single promise returning an array of the fulfilled values
    ///
    /// - Parameter promises: an array of promises of the same type
    /// - Returns: a single promise combining the resolved values of `promises`
    public static func all<Value>(_ promises: [Promise<Value>]) -> Promise<[Value]> {
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
    public static func all<Value>(_ promises: Promise<Value>...) -> Promise<[Value]> {
        return all(promises)
    }

    /// Zips the results of two promises of different types into a tuple of two elements
    ///
    /// - Parameters:
    ///   - first: The first promise of type A
    ///   - second: The second promise of type B
    /// - Returns: A promise of type Promise<(A, B)>, containing a tuple of the resolved values, or the first error returned
    public static func zip<A, B>(_ first: Promise<A>, _ second: Promise<B>) -> Promise<(A, B)> {
        return Promise<(A, B)> { (fulfill, reject) in
            let zipper = { _ in
                if let firstValue = first.value, let secondValue = second.value {
                    fulfill((firstValue, secondValue))
                }
                } as (Any) -> ()
            first.then(zipper).onError(reject)
            second.then(zipper).onError(reject)
        }
    }

    /// Zips the results of three promises of different types into a tuple of three elements
    ///
    /// - Parameters:
    ///   - first: The first promise of type A
    ///   - second: The second promise of type B
    ///   - third: The third promise of type C
    /// - Returns: A promise of type Promise<(A, B, C)>, containing a tuple of the resolved values, or the first error returned
    public static func zip<A, B, C>(_ first: Promise<A>, _ second: Promise<B>, _ third: Promise<C>) -> Promise<(A, B, C)> {
        return Promise<(A, B, C)>({ (fulfill, reject) in
            let firstZippedPair = self.zip(first, second)

            let zipper = { _ in
                if let firstValue = firstZippedPair.value, let lastValue = third.value {
                    fulfill((firstValue.0, firstValue.1, lastValue))
                }
                } as (Any) -> ()

            firstZippedPair.then(zipper).onError(reject)
            second.then(zipper).onError(reject)
        })
    }

    /// Returns the first promise resolved in an array of promises
    ///
    /// - Parameter promises: an array of promises of the same type
    /// - Returns: the first promises to resolve
    public static func race<Value>(_ promises: [Promise<Value>]) -> Promise<Value> {
        return Promise<Value> { (fulfill, reject) in
            if promises.isEmpty {
                fatalError("Cannot call `race` on an empty array")
            }
            promises.forEach {
                $0.then(fulfill).onError(reject)
            }
        }
    }
}

// Can remove on inclusion into Swift STL
extension Sequence {
    public func containsOnly(where predicate: (Element) throws -> Bool) rethrows -> Bool {
    return try !contains { try !predicate($0) }
    }
}
