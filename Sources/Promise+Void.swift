//
//  Promise+Void.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public extension Promise where Value == Void {
    public static func done() -> Promise<Value> {
        return Promise(value: ())
    }

    public func resolve() {
        futureResult.result = .success(())
    }
}
