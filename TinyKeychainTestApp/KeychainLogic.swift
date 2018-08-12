//
//  ViewController.swift
//  TinyKeychainTestApp
//
//  Created by Swain Molster on 8/12/18.
//

import Foundation
import TinyKeychain

extension Keychain {
    static let group = Keychain(group: (Bundle.main.infoDictionary!["keychainAccessGroup"] as! String))
    
    static let basic = Keychain()
}


