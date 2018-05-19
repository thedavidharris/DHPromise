//
//  Promise.swift
//  DHPromise
//
//  Created by David Harris on 02/10/17.
//  Copyright © 2017 thedavidharris. All rights reserved.
//

import Foundation

/// A representation of a Future with completion callbacks
public class Promise<Value> {

    public let futureResult: Future<Value>

    public init() {
        self.futureResult = Future<Value>()
    }

    /// - Parameter work:
    /// Initializer for the promise
    ///
    /// - Parameters:
    ///   - queue: DispatchQueue to execute work on. Defaults to DispatchQueue.global(qos: .userInitiated)
    ///   - work: Closure containing async work. Contains two internal parameters, a `resolve` closure and a `reject` closure to be executed depending on successful or unsuccessful completion of the promise
    public init(on queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated), _ work: @escaping (_ resolve: @escaping (Value) -> (), _ reject: @escaping (Error) -> ()) throws -> ()) {
        self.futureResult = Future<Value>()
        queue.async {
            do {
                try work(self.resolve, self.reject)
            } catch let error {
                self.reject(error: error)
            }
        }
    }

    /// Initialize an already resolved promise with a value
    ///
    /// - Parameter value: resolved value
    public init(value: Value) {
        self.futureResult = Future(value: value)
    }

    /// Initialize an already resolved promise with an error
    ///
    /// - Parameter error: resolved error
    public init(error: Error) {
        self.futureResult = Future(error: error)
    }

    /// Complete the Future successfully with an associated value
    ///
    /// - Parameter value: value to complete Future with
    public func resolve(value: Value) {
        futureResult.result = .success(value)
    }

    /// Complete the Future erroneously with an associated error
    ///
    /// - Parameter error: error to complete the Future with
    public func reject(error: Error) {
        futureResult.result = .failure(error)
    }
}
