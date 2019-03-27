//
//  Future+Map.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

extension Future {

    /// Chains promise objects together
    ///
    /// - Parameter onFulfilled: closure to execute upon successful completion
    /// - Returns: existing promise object
    @discardableResult
    public func flatMap<NewValue>(on queue: DispatchQueue = DispatchQueue.main, _ onFulfilled: @escaping (Value) throws -> Future<NewValue>) -> Future<NewValue> {
        return Promise<NewValue> { (fullfill, reject) in
            self.addCallback(
                on: queue,
                onFulfilled: { (value) in
                    do {
                        try onFulfilled(value).then({ (newValue) in
                            fullfill(newValue)
                        }).catch({ (error) in
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
}
