//
//  KeychainManager.swift
//  Authentication
//
//  Created by Hussaan S on 25/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
/**
    conversion of CFString(Security) to String
 */
private let SecMatchLimit: String! = kSecMatchLimit as String
private let SecReturnData: String! = kSecReturnData as String
private let SecValueData: String! = kSecValueData as String
private let SecAttrAccessible: String! = kSecAttrAccessible as String
private let SecClass: String! = kSecClass as String
private let SecAttrService: String! = kSecAttrService as String
private let SecAttrGeneric: String! = kSecAttrGeneric as String
private let SecAttrAccount: String! = kSecAttrAccount as String

public class KeychainManager {
    
    private(set) var serviceName: String
    
    public init(serviceName: String) {
        self.serviceName = serviceName
    }
    
    /**
     Setup a keychain query with kSecClass: Generic Password
     - parameters:
     - key: key value of keychain item
     - accessibility: accessibility of keychain item
     */
    private func setupKeychainQueryDictionary(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> [String: Any] {
        
        var keychainQueryDictionary: [String: Any] = [SecClass: kSecClassGenericPassword]
        
        keychainQueryDictionary[SecAttrService] = serviceName
        
        if let accessibility = accessibility {
            keychainQueryDictionary[SecAttrAccessible] = accessibility.keychainAttrValue
        }
        
        let encodedIdentifier: Data? = key.data(using: String.Encoding.utf8)
        
        keychainQueryDictionary[SecAttrGeneric] = encodedIdentifier
        
        keychainQueryDictionary[SecAttrAccount] = encodedIdentifier
        
        return keychainQueryDictionary
    }
}

// MARK: get keychain item
extension KeychainManager {
    
    open func string(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> String? {
        guard let keychainData = data(forKey: key, withAccessibility: accessibility) else {
            return nil
        }
        return String(data: keychainData, encoding: String.Encoding.utf8) as String?
    }
    
    open func data(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Data? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)
        
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne
        keychainQueryDictionary[SecReturnData] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)
        
        return status == noErr ? result as? Data : nil
    }
}

// MARK: Set Keychain Item
extension KeychainManager {
    
    @discardableResult open func set(_ value: Data, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Bool {
        var keychainQueryDictionary: [String: Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)
        
        keychainQueryDictionary[SecValueData] = value
        
        let status: OSStatus = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            return update(value, forKey: key, withAccessibility: accessibility)
        } else {
            return false
        }
    }
    
    private func update(_ value: Data, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Bool {
        let keychainQueryDictionary: [String: Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)
        let updateDictionary = [SecValueData: value]
        
        let status: OSStatus = SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary)
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
}

// MARK: Keychain Delete Items
extension KeychainManager {
    
    @discardableResult open func removeObject(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Bool {
        let keychainQueryDictionary: [String: Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)
        let status: OSStatus = SecItemDelete(keychainQueryDictionary as CFDictionary)
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    @discardableResult open func removeAllKeys() -> Bool {
        var keychainQueryDictionary: [String: Any] = [SecClass: kSecClassGenericPassword]
        keychainQueryDictionary[SecAttrService] = serviceName
        let status: OSStatus = SecItemDelete(keychainQueryDictionary as CFDictionary)
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
}

// MARK: Keychain Clear Mechanism
extension KeychainManager {

    open class func wipeKeychain() {
        deleteKeychainSecClass(kSecClassGenericPassword)
    }
    
    @discardableResult private class func deleteKeychainSecClass(_ secClass: AnyObject) -> Bool {
        let query = [SecClass: secClass]
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
}
