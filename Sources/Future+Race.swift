//
//  Future+Race.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Future {

    /// Returns the first promise resolved in an array of promises
    ///
    /// - Parameter promises: an array of promises of the same type
    /// - Returns: the first promises to resolve
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

    public static func race(_ futures: Future<Value>...) -> Future<Value> {
        return race(futures)
    }
}

public func race<A, B>(_ first: Future<A>, _ second: Future<B>) -> Future<Either<A, B>> {
    return Promise<Either<A, B>> { (fulfill, reject) in
        first.then { fulfill(.Left($0)) }.catch(reject)
        second.then { fulfill(.Right($0)) }.catch(reject)
    }.futureResult
}

public func race<A, B, C>(_ first: Future<A>, _ second: Future<B>, _ third: Future<C>) -> Future<Any> {
    return Promise<Any> { (fulfill, reject) in
        first.then { fulfill($0) }.catch(reject)
        second.then { fulfill($0) }.catch(reject)
        third.then { fulfill($0) }.catch(reject)
    }.futureResult
}


