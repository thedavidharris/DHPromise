//
//  Helpers.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

// Can remove on inclusion into Swift STL
internal extension Sequence {
    func containsOnly(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try !contains { try !predicate($0) }
    }

    #if !swift(>=4.1)
    func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try self.map(transform).filter { $0 != nil }.map { $0! }
    }
    #endif
}

