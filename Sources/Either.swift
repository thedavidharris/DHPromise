//
//  Either.swift
//  Futura
//
//  Created by David Harris on 5/18/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public enum Either<A, B>{
    case Left(A)
    case Right(B)
}
