//
//  TestHelpers.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation
import Futura

enum TestError: Error, Equatable {
    case test
}

func asyncFuture<T>(from result: Result<T, Error>, delay: TimeInterval = 0.1) -> Future<T> {
    return Promise({ (resolve, reject) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            switch result {
            case .success(let value):
                return resolve(value)
            case .failure(let error):
                return reject(error)
            }
        }
    }).futureResult
}

func throwingFuture<T>(successValue: T, shouldThrow: Bool) throws -> Future<T> {
    if shouldThrow {
        throw TestError.test
    }
    return Promise<T>(value: successValue).futureResult
}
