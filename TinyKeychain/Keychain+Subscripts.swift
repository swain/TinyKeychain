//
//  Keychain+Subscripts.swift
//  TinyKeychain
//
//  Created by Swain Molster on 5/9/18.
//  Copyright © 2018 Swain Molster. All rights reserved.
//

import Foundation

extension Keychain {
    
    /**
     Subscript function for storing/retrieving/deleting values. Setting to `nil` is equivalent to a deletion.
     
     - Note: No error handling is done here. If a retrieval fails, nil will be returned. Additionally, all storage and deletion calls are "fire-and-forget"--they may or may not succeed, and there will be no error notification if they do not.
     */
    
    public subscript<Object>(key: Key<Object>) -> Object? {
        get {
            switch self.retrieveObject(forKey: key) {
            case .success(let object):
                return object
            case .error:
                return nil
            }
        }
        
        set {
            if let newValue = newValue {
                self.storeObject(newValue, forKey: key)
            } else {
                self.deleteObject(forKey: key)
            }
        }
    }
}
