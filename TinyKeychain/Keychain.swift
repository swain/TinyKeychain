//
//  Keychain.swift
//  TinyKeychain
//
//  Created by Swain Molster on 5/9/18.
//  Copyright © 2018 Swain Molster. All rights reserved.
//

import Foundation

/**
 Model representation of the Keychain. Allows for storage, retrieval, and deletion.
 
 Every `Keychain` instance is associated with a single keychain access group. It is safe to recreate a `Keychain` instance using the same keychain access group multiple times, and access the same keys.
 
 _Recommended Usage_:
 
 ```
 extension Keychain {
    static var `default`: Keychain {
        return Keychain(keychainAccessGroup: "my.keychain.access.group.here"
    }
 }
 ```
 
 `Keychain` objects also support storage/retrieval/deletion using subscripts, with a `Keychain.Key` used as the index:
 ```
 // Storage
 Keychain.default[.authToken] = newToken
 
 // Retrieval
 let token = Keychain.default[.authToken]
 
 // Deletion
 Keychain.default[.authToken] = nil
 ```
 */
public class Keychain {
    
    /**
     Represents an accessibility level of a `Keychain`.
     */
    public enum AccessibilityLevel {
        /// Maps to `kSecAttrAccessibleWhenUnlocked`.
        case whenUnlocked
        
        /// Maps to `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
        case whenUnlockedThisDeviceOnly
        
        /// Maps to `kSecAttrAccessibleAfterFirstUnlock`.
        case afterFirstUnlock
        
        /// Maps to `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
        case afterFirstUnlockThisDeviceOnly
        
        /// Maps to `kSecAttrAccessibleAlways`.
        case alwaysAccessible
        
        /// Maps to `kSecAttrAccessibleAlwaysThisDeviceOnly`.
        case alwaysAccessibleThisDeviceOnly
        
        /// Maps to `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`.
        case whenPasscodeSetThisDeviceOnly
        
        public var valueForQuery: CFString {
            switch self {
            case .whenUnlocked:
                return kSecAttrAccessibleWhenUnlocked
            case .whenUnlockedThisDeviceOnly:
                return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                
            case .afterFirstUnlock:
                return kSecAttrAccessibleAfterFirstUnlock
            case .afterFirstUnlockThisDeviceOnly:
                return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
                
            case .always:
                return kSecAttrAccessibleAlways
            case .alwaysThisDeviceOnly:
                return kSecAttrAccessibleAlwaysThisDeviceOnly
                
            case .whenPasscodeSetThisDeviceOnly:
                return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            }
        }
        
        /// Whether or not this accessibility level is compatible with iCloud synchronization
        public var synchronizationIsPossible: Bool {
            switch self {
                case .afterFirstUnlock,
                     .always,
                     .whenUnlocked:
                return true
                
                case .afterFirstUnlockThisDeviceOnly,
                     .alwaysThisDeviceOnly,
                     .whenPasscodeSetThisDeviceOnly,
                     .whenUnlockedThisDeviceOnly:
                return false
            }
        }
    }
    
    // The three properties below are marked fileprivate mainly for the purpose of keeping the name space clean.
    
    /// The keychain access group associated with this keychain.
    public let keychainAccessGroup: String
    
    /// The security level to use when accessing this keychain.
    public let accessibilityLevel: AccessibilityLevel
    
    /**
     Initializes and returns a `Keychain` associated with the provided `keychainAccessGroup`.
     
     - Parameters:
        - keychainAccessGroup: The keychain access group to associate with this keychain.
        - accessibilityLevel: The accessibility level to associate with this keychain. Defaults to `.whenUnlocked`.
     */
    public init(keychainAccessGroup: String, accessibilityLevel: AccessibilityLevel = .whenUnlocked) {
        self.keychainAccessGroup = keychainAccessGroup
        self.accessibilityLevel = accessibilityLevel
    }
    
    /**
     Stores an `object` in the keychain using a `key`, or updates the object if it already it exists.
     
     - Parameters:
        - object: The object to store.
        - key: The key to use.
     
     - returns: Either success, or a `Keychain.StoringError`.
     */
    @discardableResult
    public func storeObject<O>(_ object: O, forKey key: Key<O>) -> KeychainResult<Void, StoringError> {
        var query = self.getBaseKeychainQuery(forKey: key)
        
        let data: Data
        do {
            data = try JSONEncoder().encode(object)
        } catch let error {
            return .error(.encodingError(error))
        }
        query[kSecValueData] = data
        
        var status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        
        // Object already exists, so we update it
        if status == errSecDuplicateItem {
            let updateDictionary = [kSecValueData: data]
            status = SecItemUpdate(query as CFDictionary, updateDictionary as CFDictionary)
        }
        
        if status != noErr {
            return .error(.couldNotStore(status))
        }
        
        return .success(())
    }
    
    /**
     Retrieves an object from the keychain using a `key`.
     
     - parameter key: The key.
     - returns: Either the requested object, or a `Keychain.RetrievalError`.
     */
    public func retrieveObject<O>(forKey key: Key<O>) -> KeychainResult<O, RetrievalError> {
        var query = self.getBaseKeychainQuery(forKey: key)
        
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitOne
        
        var keyData: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &keyData)
        
        if status == noErr {
            guard let data = keyData as? Data else {
                return .error(.objectNotFound(keyRawValue: key.rawValue))
            }
            do {
                return .success(try JSONDecoder().decode(O.self, from: data))
            } catch let error {
                return .error(.decodingError(error))
            }
        } else {
            return .error(.couldNotRetrieve(status))
        }
    }
    
    /**
     Deletes an object from the keychain, returning either success or a `Keychain.DeletionError`.
     
     - parameter key: The key.
     - returns: Either success, or a `Keychain.DeletionError`.
     */
    @discardableResult
    public func deleteObject<O>(withKey key: Key<O>) -> KeychainResult<Void, DeletionError> {
        let query = self.getBaseKeychainQuery(forKey: key)
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        if status != noErr {
            return .error(.couldNotDelete(keyRawValue: key.rawValue, status))
        }
        return .success(())
    }
}

extension Keychain {
    
    /**
     Creates a query for the provided `key`.
     
     - parameter key: The key to use for creating the query.
     - returns: A dictionary to be used for querying the keychain.
     */
    private func getBaseKeychainQuery<O>(forKey key: Key<O>) -> [CFString: Any] {
        var dict: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key.rawValue,
            kSecAttrAccount: key.rawValue,
            kSecAttrAccessible: self.accessibilityLevel.valueForQuery,
            kSecAttrAccessGroup: self.keychainAccessGroup
        ]
        
        if key.isSynchronizing {
            precondition(self.accessibilityLevel.synchronizationIsPossible, "You tried to use a synchronizing Keychain.Key with a Keychain using an accessibility level that doesn't support synchronization.")
            dict[kSecAttrSynchronizable] = kCFBooleanTrue
        }
        
        return dict
    }
}
