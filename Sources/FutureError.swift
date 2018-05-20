//
//  FutureError.swift
//  Futura
//
//  Created by David Harris on 5/20/18.
//  Copyright © 2018 thedavidharris. All rights reserved.
//

import Foundation

public enum FutureError: Error {
    case emptyRace
    case timeout
    case validationFailed
}
