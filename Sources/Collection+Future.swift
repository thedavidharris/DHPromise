//
//  Collection+Future.swift
//  Futura
//
//  Created by David Harris on 5/20/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Collection where Element: FutureType {
    public func firstCompleted(on queue: DispatchQueue = DispatchQueue.main) -> Future<Element.Expectation> {
        return Promise<Element.Expectation> { (fulfill, reject) in
            if self.isEmpty {
                reject(FutureError.emptyRace)
            }
            self.forEach {
                $0.then(on: queue, fulfill).catch(reject)
            }
        }.futureResult
    }

    public func flatten(on queue: DispatchQueue = DispatchQueue.main) -> Future<[Element.Expectation]> {
        return Promise<[Element.Expectation]>{ (fullfill, reject) in
            if self.isEmpty {
                fullfill([])
            }

            for future in self {
                future.then(on: queue) { _ in
                    if self.containsOnly(where: { $0.state == .resolved }) {
                        fullfill(self.compactMap { $0.value })
                    }
                }.catch { error in
                    reject(error)
                }
            }
        }.futureResult
    }
}
