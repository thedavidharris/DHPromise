//
//  Future+Wrap.swift
//  Futura
//
//  Created by David Harris on 5/30/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Future {
    public static func wrap<T>(completion: @escaping (@escaping (T?, Error?) -> Void) -> Void) -> Future<T> {
        return Promise { (fulfill, reject) in
            completion { value, error in
                let result = Result(value: value, error: error)
                switch result {
                case .success(let value):
                    return fulfill(value)
                case .failure(let error):
                    return reject(error)
                }
            }
        }.futureResult
    }

    public static func wrap<T: ResultType>(completion: @escaping ((T) -> Void) -> Void) -> Future<T.Value> {
        return Promise { (fulfill, reject) in
            completion { resultType in
                switch resultType.result {
                case .success(let value):
                    return fulfill(value)
                case .failure(let error):
                    return reject(error)
                }
            }
        }.futureResult
    }
}
