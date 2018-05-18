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

    let futureResult: Future<Value>

    

    /// - Parameter work:
    /// Initializer for the promise
    ///
    /// - Parameters:
    ///   - queue: DispatchQueue to execute work on. Defaults to DispatchQueue.global(qos: .userInitiated)
    ///   - work: Closure containing async work. Contains two internal parameters, a `resolve` closure and a `reject` closure to be executed depending on successful or unsuccessful completion of the promise
    public init(on queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated), _ work: @escaping (_ resolve: @escaping (Value) -> (), _ reject: @escaping (Error) -> ()) throws -> ()) {
        self.futureResult = Future<Value>(result: nil)
        queue.async {
            do {
                try work(self.resolve, self.reject)
            } catch let error {
                self.reject(error: error)
            }
        }
    }

    public func resolve(value: Value) {
        futureResult.result = .success(value)
    }

    public func reject(error: Error) {
        futureResult.result = .failure(error)
    }
}



/// Namespace for Promise functions
public enum DHPromise {

    enum Problem: Error {
        case emptyRace
        case invalidInput
        case timeout
        case validationFailed
    }

    /// Resolve multiple promises of the same type into a single promise returning an array of the fulfilled values
    ///
    /// - Parameter promises: an array of promises of the same type
    /// - Returns: a single promise combining the resolved values of `promises`
    public static func all<Value>(_ promises: [Future<Value>]) -> Future<[Value]> {
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
        }.futureResult
    }

    /// Variadic implemention of resolving all promises
    ///
    /// - Parameter promises: an array of promises of the same type
    /// - Returns: a single promise combining the resolved values of `promises`
    public static func all<Value>(_ promises: Future<Value>...) -> Future<[Value]> {
        return all(promises)
    }

    /// Zips the results of two promises of different types into a tuple of two elements
    ///
    /// - Parameters:
    ///   - first: The first promise of type A
    ///   - second: The second promise of type B
    /// - Returns: A promise of type Promise<(A, B)>, containing a tuple of the resolved values, or the first error returned
    public static func zip<A, B>(_ first: Future<A>, _ second: Future<B>) -> Future<(A, B)> {
        return Promise<(A, B)> { (fulfill, reject) in
            let zipper = { _ in
                if let firstValue = first.value, let secondValue = second.value {
                    fulfill((firstValue, secondValue))
                }
            } as (Any) -> ()
            first.then(zipper).onError(reject)
            second.then(zipper).onError(reject)
        }.futureResult
    }

    /// Zips the results of three promises of different types into a tuple of three elements
    ///
    /// - Parameters:
    ///   - first: The first promise of type A
    ///   - second: The second promise of type B
    ///   - third: The third promise of type C
    /// - Returns: A promise of type Promise<(A, B, C)>, containing a tuple of the resolved values, or the first error returned
    public static func zip<A, B, C>(_ first: Future<A>, _ second: Future<B>, _ third: Future<C>) -> Future<(A, B, C)> {
        return Promise<(A, B, C)>({ (fulfill, reject) in
            let firstZippedPair = self.zip(first, second)

            let zipper = { _ in
                if let firstValue = firstZippedPair.value, let lastValue = third.value {
                    fulfill((firstValue.0, firstValue.1, lastValue))
                }
            } as (Any) -> ()

            firstZippedPair.then(zipper).onError(reject)
            third.then(zipper).onError(reject)
        }).futureResult
    }

    /// Returns the first promise resolved in an array of promises
    ///
    /// - Parameter promises: an array of promises of the same type
    /// - Returns: the first promises to resolve
    public static func race<Value>(_ promises: [Future<Value>]) -> Future<Value> {
        return Promise<Value> { (fulfill, reject) in
            if promises.isEmpty {
                reject(DHPromise.Problem.emptyRace)
            }
            promises.forEach {
                $0.then(fulfill).onError(reject)
            }
        }.futureResult
    }

    @discardableResult
    public static func retry<Value>(attempts: Int, delay delayTime: TimeInterval, retryBody: @escaping () -> Future<Value>) -> Future<Value> {

        var attemptsLeft = attempts

        func attempt() -> Future<Value> {
            return retryBody().recover { error in
                guard attemptsLeft > 0 else {
                    throw error
                }
                attemptsLeft -= 1
                return attempt().delay(delayTime)
            }
        }

        return attempt()
    }
}

// Can remove on inclusion into Swift STL
extension Sequence {
    public func containsOnly(where predicate: (Element) throws -> Bool) rethrows -> Bool {
    return try !contains { try !predicate($0) }
    }
}
