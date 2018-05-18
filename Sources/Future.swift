//
//  Future.swift
//  DHPromise
//
//  Created by David Harris on 5/17/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

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

public class Future<Value> {

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

    /// Private underlying value of Promise.result for thread-safe access
    private var _result: Result<Value>?

    /// Result value of the promise
    public var result: Result<Value>? {
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


    /// Convenience accessor for the associated value of the promise
    public var value: Value? {
        return result?.value
    }

    /// Convenience accessor for the associated value of the promise
    public var error: Error? {
        return result?.error
    }

    lazy var callbacks = [Callback<Value>]()

    /// Locked queue to allow for thread-safety within the Future object
    private let lockQueue = DispatchQueue(label: "future_lock_queue", qos: .userInitiated)


    init(result: Result<Value>?) {
        self.result = result
    }

    init(value: Value) {
        self.result = .success(value)
    }

    init(error: Error) {
        self.result = .failure(error)
    }

    /// Execute a closure upon successful completion of the promise
    ///
    /// - Parameter callback: closure to execute upon completion of the promise
    /// - Returns: the existing promise object
    @discardableResult
    public func then(on queue: DispatchQueue = DispatchQueue.main, _ onFulfilled: @escaping (Value) -> Void) -> Future<Value> {
        addCallbacks(on: queue, onFulfilled: onFulfilled)
        return self
    }

    /// Execute a closure upon unsuccessful completion of the promise
    ///
    /// - Parameter callback: closure to execute upon completion of the promise
    /// - Returns: the existing promise object
    @discardableResult
    public func onError(on queue: DispatchQueue = DispatchQueue.main, _ onRejected: @escaping (Error) -> Void) -> Future<Value> {
        addCallbacks(on: queue, onRejected: onRejected)
        return self
    }

    /// Execute a closure on completion of promise in both fulfilled and error states
    ///
    /// - Parameter onFinally: closure to execute upon completion
    /// - Returns: the existing promise object
    @discardableResult
    public func finally(_ onFinally: @escaping () -> ()) -> Future<Value> {
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
    public func flatMap<NewValue>(on queue: DispatchQueue = DispatchQueue.main, _ onFulfilled: @escaping (Value) throws -> Future<NewValue>) -> Future<NewValue> {
        return Promise<NewValue> { (fullfill, reject) in
            self.addCallbacks(
                on: queue,
                onFulfilled: { (value) in
                    do {
                        try onFulfilled(value).then({ (newValue) in
                            fullfill(newValue)
                        }).onError({ (error) in
                            reject(error)
                        })
                    } catch {
                        reject(error)
                    }
            }, onRejected: { (error) in
                reject(error)
            })
        }.futureResult
    }

    /// Maps the underlying type in the Promise object
    ///
    /// - Parameter onFulfilled: closure to execute upon successful completion
    /// - Returns: the existing promise object
    @discardableResult
    public func map<NewValue>(_ onFulfilled: @escaping (Value) throws -> NewValue) -> Future<NewValue> {
        return flatMap { (value) in
            do {
                return Future<NewValue>(value: try onFulfilled(value))
            } catch {
                return Future<NewValue>(error: error)
            }
        }
    }

    private func addCallbacks(on queue: DispatchQueue, onFulfilled: ((Value) -> ())? = nil, onRejected: ((Error) -> ())? = nil) {
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

    @discardableResult
    public func delay(_ timeInterval: TimeInterval) -> Future<Value> {
        return Promise<Void> { (fulfill, reject) in
            DispatchQueue.global().asyncAfter(deadline: .now() + timeInterval, execute: {
                    fulfill(())
                })
            }.futureResult.flatMap { _ in self }
    }

    @discardableResult
    public func recover(_ recoverBlock: @escaping (Error) throws -> Future<Value>) -> Future<Value> {
        return Promise { fulfill, reject in
            self.then(fulfill).onError({ error in
                do {
                    try recoverBlock(error).then(fulfill).onError(reject)
                } catch (let error) {
                    reject(error)
                }
            })
        }.futureResult
    }

    @discardableResult
    public func validate(_ validate: @escaping (Value) throws -> Bool) -> Future<Value> {
        return self.map({ (value)  in
            guard try validate(value) else {
                throw DHPromise.Problem.validationFailed
            }
            return value
        })
    }

    // TODO: This timeout is not quite accurate, needs work with the queues
    @discardableResult
    public func timeout(_ timeInterval: TimeInterval) -> Future<Value> {
        return Promise<Value> { (fulfill, reject) in
            DispatchQueue.global().asyncAfter(deadline: .now() + timeInterval, execute: {
                reject(DHPromise.Problem.timeout)
            })

            self.then(fulfill).onError(reject)
        }.futureResult
    }
}

