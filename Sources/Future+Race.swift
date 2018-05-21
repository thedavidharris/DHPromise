//
//  Future+Race.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Future {

    /// Returns the first Future resolved in an array of Futures
    ///
    /// - Parameter promises: an array of Future of the same type
    /// - Returns: the first Future to resolve
    public static func race(_ futures: [Future<Value>]) -> Future<Value> {
        return Promise<Value> { (fulfill, reject) in
            if futures.isEmpty {
                reject(FutureError.emptyRace)
            }
            futures.forEach {
                $0.then(fulfill).catch(reject)
            }
        }.futureResult
    }

    /// Variadic implemention of `race`
    ///
    /// - Parameter futures: Futures to race
    /// - Returns: first Future to resolve
    public static func race(_ futures: Future<Value>...) -> Future<Value> {
        return race(futures)
    }
}

/// Races two Futures of different types
///
/// - Parameters:
///   - first: first Future
///   - second: second Future
/// - Returns: the first Future to resolve encapsulated in an Either enum with either the first Future as .Left, or the second Future as Right
public func race<A, B>(_ first: Future<A>, _ second: Future<B>) -> Future<Either<A, B>> {
    return Promise<Either<A, B>> { (fulfill, reject) in
        first.then { fulfill(.Left($0)) }.catch(reject)
        second.then { fulfill(.Right($0)) }.catch(reject)
    }.futureResult
}

/// Races three Futures of different types
///
/// - Parameters:
///   - first: first Future
///   - second: second Future
///   - third: third Future
/// - Returns: the first Future to resolve, as a Future<Any> due to inability to resolve type at compile time
public func race<A, B, C>(_ first: Future<A>, _ second: Future<B>, _ third: Future<C>) -> Future<Any> {
    return Promise<Any> { (fulfill, reject) in
        first.then { fulfill($0) }.catch(reject)
        second.then { fulfill($0) }.catch(reject)
        third.then { fulfill($0) }.catch(reject)
    }.futureResult
}


