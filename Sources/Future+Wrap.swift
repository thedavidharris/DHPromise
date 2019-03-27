//
//  Future+Wrap.swift
//  Futura
//
//  Created by David Harris on 5/30/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

extension Future {
    public static func wrap<T>(completion: @escaping (@escaping (T?, Error?) -> Void) -> Void) -> Future<T> {
        return Promise { (fulfill, reject) in
            completion { value, error in
                let result: Result<T, Error>
                if let value = value {
                    result = .success(value)
                } else if let error = error {
                    result = .failure(error)
                } else {
                    result = .failure(FutureError.invalidWrapParameters)
                }
                switch result {
                case .success(let value):
                    return fulfill(value)
                case .failure(let error):
                    return reject(error)
                }
            }
        }.futureResult
    }

    public static func wrap<T>(completion: @escaping (@escaping (Result<T, Error>) -> Void) -> Void) -> Future<T> {
        return Promise { (fulfill, reject) in
            completion { result in
                switch result {
                case .success(let value):
                    return fulfill(value)
                case .failure(let error):
                    return reject(error)
                }
            }
        }.futureResult
    }
}
