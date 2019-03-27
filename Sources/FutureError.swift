//
//  FutureError.swift
//  Futura
//
//  Created by David Harris on 5/20/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

/// Errors throw by the Futura library
///
/// - emptyRace: `race` called with no Futures
/// - timeout: Future timed out
/// - validationFailed: Future failed validation
/// - invalidWrapParameters: `Future.wrap` called with nil parameters
public enum FutureError: Error {
    case emptyRace
    case timeout
    case validationFailed
    case invalidWrapParameters
}
