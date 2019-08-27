//
//  KeychainKey.swift
//  TinyKeychain
//
//  Created by Swain Molster on 5/9/18.
//  Copyright © 2018 Swain Molster. All rights reserved.
//

import Foundation

public extension Keychain {
    
    /**
     Generic key object used for interacting with a `Keychain`.
     
     `Object` corresponds to the type that this key is associated with. Storing/retrieving using a key involves strong type-checking to `Object`.
     
     - Warning: It is strongly recommended that you do not make use of the same raw value across multiple keys.
     
     _Recommended Usage_:
     ```
     extension Keychain.Key {
        static var authToken: Keychain.Key<MyToken> {
            return Keychain.Key<MyToken>(rawValue: "my.auth.token.key.here"
        }
     }
     
     func retrieveToken() {
        switch aKeychain.retrieveObject(forKey: .authToken) {
        case .success(let token):
            // Do something with `token`
        case .error(let storingError):
            // Handle error
        }
     }
     ```
     
     */
    struct Key<Object: Codable> {
        /// The raw value of the key.
        public let rawValue: String
        
        /// Whether or not values stored using this key should synchronize in iCloud. Defaults to false.
        public let isSynchronizing: Bool
        
        /**
         Initializes and returns a `Key` with the associated raw value.
         
         - Parameters:
            - rawValue: The raw `String` value to use for keying the keychain.
            - synchronize: Whether or not values stored using this key should synchronize in iCloud. Defaults to false.
         */
        public init(rawValue: String, synchronize: Bool = false) {
            self.rawValue = rawValue
            self.isSynchronizing = synchronize
        }
    }
}
