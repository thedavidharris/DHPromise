//
//  Future+Variadic.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Future {
    /// Resolve multiple futures of the same type into a single future returning an array of the fulfilled values
    ///
    /// - Parameter futures: an array of futures of the same type
    /// - Returns: a single promise combining the resolved values of `futures`
    public static func all<Value>(_ futures: [Future<Value>]) -> Future<[Value]> {
        return Promise<[Value]>{ (fullfill, reject) in
            if futures.isEmpty {
                fullfill([])
            }
            futures.forEach({ (future) in
                future.then({ _ in
                    if futures.containsOnly(where: { $0.state == .resolved }) {
                        fullfill(futures.compactMap({ $0.value }))
                    }
                }).catch({ (error) in
                    reject(error)
                })
            })
        }.futureResult
    }

    /// Variadic implemention of resolving all futures
    ///
    /// - Parameter futures: an array of futures of the same type
    /// - Returns: a single future combining the resolved values of `futures`
    public static func all<Value>(_ futures: Future<Value>...) -> Future<[Value]> {
        return all(futures)
    }
}

/// Zips the results of two futures of different types into a tuple of two elements
///
/// - Parameters:
///   - first: The first future of type A
///   - second: The second future of type B
/// - Returns: A future of type Future<(A, B)>, containing a tuple of the resolved values, or the first error returned
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

/// Zips the results of three futures of different types into a tuple of three elements
///
/// - Parameters:
///   - first: The first future of type A
///   - second: The second future of type B
///   - third: The third future of type C
/// - Returns: A future of type Future<(A, B, C)>, containing a tuple of the resolved values, or the first error returned
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



