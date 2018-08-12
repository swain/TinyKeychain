//
//  TinyKeychainTests.swift
//  TinyKeychainTests
//
//  Created by Swain Molster on 8/12/18.
//

import XCTest
import TinyKeychain
@testable import TinyKeychainTestApp

extension Keychain.Key {
    static var sampleKey: Keychain.Key<TestObject> { return .init(rawValue: "sampleKey") }
}

struct TestObject: Codable {
    let value: String
}

class TinyKeychainTests: XCTestCase {
    
    override func setUp() {
        Keychain.group.deleteObject(forKey: .sampleKey)
    }
    
    func testStore() {
        
        let sampleValue = "storeTest"
        
        let storageResult = Keychain.group.storeObject(TestObject(value: sampleValue), forKey: .sampleKey)
        
        if case .error(let err) = storageResult {
            XCTFail("Storing object should not fail. Error: \(err)")
        }
        
        switch Keychain.group.retrieveObject(forKey: .sampleKey) {
        case .success(let obj):
            XCTAssert(obj.value == sampleValue)
        case .error(let err):
            XCTFail("Should be able to retrieve object just after storage without error. Error: \(err)")
        }
    }
    
    func testOverwrite() {
        let sampleValueOne = "overwriteTestOne"
        
        let sampleValueTwo = "overwriteTestTwo"
        
        Keychain.group.storeObject(TestObject(value: sampleValueOne), forKey: .sampleKey)
        
        Keychain.group.storeObject(TestObject(value: sampleValueTwo), forKey: .sampleKey)
        
        switch Keychain.group.retrieveObject(forKey: .sampleKey) {
        case .success(let obj):
            XCTAssert(obj.value == sampleValueTwo)
        case .error(let err):
            XCTFail("Should be able to retrieve object just after storage without error. Error: \(err)")
        }
    }
    
    func testDelete() {
        let sampleValue = "deleteTest"
        
        Keychain.group.storeObject(TestObject(value: sampleValue), forKey: .sampleKey)
        
        Keychain.group.deleteObject(forKey: .sampleKey)
        
        let retrievalResult = Keychain.group.retrieveObject(forKey: .sampleKey)
        
        guard case .error(.couldNotRetrieve) = retrievalResult else {
            XCTFail("Retrieval should fail immediately after deletion.")
            return
        }
    }
}
