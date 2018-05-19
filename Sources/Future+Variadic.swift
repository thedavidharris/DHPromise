//
//  Future+Variadic.swift
//  DHPromise
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Future {
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
                }).catch({ (error) in
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
}

/// Zips the results of two promises of different types into a tuple of two elements
///
/// - Parameters:
///   - first: The first promise of type A
///   - second: The second promise of type B
/// - Returns: A promise of type Promise<(A, B)>, containing a tuple of the resolved values, or the first error returned
public func zip<A, B>(_ first: Future<A>, _ second: Future<B>) -> Future<(A, B)> {
    return Promise<(A, B)> { (fulfill, reject) in
        let zipper = { _ in
            if let firstValue = first.value, let secondValue = second.value {
                fulfill((firstValue, secondValue))
            }
            } as (Any) -> ()
        first.then(zipper).catch(reject)
        second.then(zipper).catch(reject)
        }.futureResult
}

/// Zips the results of three promises of different types into a tuple of three elements
///
/// - Parameters:
///   - first: The first promise of type A
///   - second: The second promise of type B
///   - third: The third promise of type C
/// - Returns: A promise of type Promise<(A, B, C)>, containing a tuple of the resolved values, or the first error returned
public func zip<A, B, C>(_ first: Future<A>, _ second: Future<B>, _ third: Future<C>) -> Future<(A, B, C)> {
    return Promise<(A, B, C)>({ (fulfill, reject) in
        let firstZippedPair = zip(first, second)

        let zipper = { _ in
            if let firstValue = firstZippedPair.value, let lastValue = third.value {
                fulfill((firstValue.0, firstValue.1, lastValue))
            }
            } as (Any) -> ()

        firstZippedPair.then(zipper).catch(reject)
        third.then(zipper).catch(reject)
    }).futureResult
}



