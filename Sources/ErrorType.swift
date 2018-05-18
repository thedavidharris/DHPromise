//
//  ErrorType.swift
//  DHPromise
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

enum Problem: Error {
    case emptyRace
    case invalidInput
    case timeout
    case validationFailed
}
