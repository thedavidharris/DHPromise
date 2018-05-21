//
//  Either.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

/// Functional enum to represent a binary option
///
/// - Left: one option
/// - Right: the other option
public enum Either<A, B>{
    case Left(A)
    case Right(B)
}
