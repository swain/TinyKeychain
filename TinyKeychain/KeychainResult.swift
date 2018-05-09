//
//  KeychainResult.swift
//  TinyKeychain
//
//  Created by Swain Molster on 5/9/18.
//  Copyright © 2018 Swain Molster. All rights reserved.
//

import Foundation

/// Simple generic result object with `success` and `error` cases.
public enum KeychainResult<S, E: Error> {
    case success(S)
    case error(E)
}
