//
//  CredentialsManager.swift
//  YAPPakistan_Example
//
//  Created by Umer on 04/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

public protocol CredentialsStoreType {
    var isCredentialsAvailable: Bool {  get }
    var userCountry: String? {  get }
    @discardableResult
    func secureCredentials(username: String, passcode: String) -> Bool
    func getUsername() -> String?
    func getPasscode(username: String) -> String?
    func secure(passcode: String) -> Bool
}


public class CredentialsManager: CredentialsStoreType {
    
    private let keychainManager: KeychainManager
    private let usernameKey = "yapUsername"
    private let rememberIdKey = "yapRememberUsername"
    
    public init(keychainManager: KeychainManager = KeychainManager(serviceName: "co.yap.keychain") ) {
        self.keychainManager = keychainManager
    }
 
    public func secure(username: String) -> Bool {
        guard let usernameData = username.data(using: .utf8) else { return false }
        return keychainManager.set(usernameData, forKey: usernameKey, withAccessibility: .whenPasscodeSetThisDeviceOnly)
    }
    
    public func secure(passcode: String) -> Bool {
        guard let passcodeData = passcode.data(using: .utf8), let username = getUsername() else { return false }
        return keychainManager.set(passcodeData, forKey: username, withAccessibility: .whenPasscodeSetThisDeviceOnly)
    }
    
    public func secure(passcode: String, username: String) -> Bool {
        guard let passcodeData = passcode.data(using: .utf8) else { return false }
        return keychainManager.set(passcodeData, forKey: username, withAccessibility: .whenPasscodeSetThisDeviceOnly)
    }
    
    @discardableResult
    public func secureCredentials(username: String, passcode: String) -> Bool {
        return (secure(username: username) && secure(passcode: passcode, username: username))
    }
    
    public func getUsername() -> String? {
        return keychainManager.string(forKey: usernameKey, withAccessibility: .whenPasscodeSetThisDeviceOnly)
    }
    
    public func getPasscode(username: String) -> String? {
        return keychainManager.string(forKey: username, withAccessibility: .whenPasscodeSetThisDeviceOnly)
    }
    
    @discardableResult
    public func clearCredentials(username: String) -> Bool {
        return (clearPasscode(username: username) && clearUsername())
    }
    
    public func clearUsername() -> Bool {
        guard !(remembersId ?? false) else { return false }
        return keychainManager.removeObject(forKey: usernameKey)
    }
    
    public func clearPasscode(username: String) -> Bool {
        return keychainManager.removeObject(forKey: username)
    }
    
    public var isCredentialsAvailable: Bool {
        guard let username = getUsername() else { return false }
        guard !(getPasscode(username: username)?.isEmpty ?? true) else { return false }
        return true
    }
    
    public var userCountry: String? {
        return "PK"
    }
    
    public func credentialsAvailable() -> Bool {
        guard let username = getUsername() else { return false }
        guard !(getPasscode(username: username)?.isEmpty ?? true) else { return false }
        return true
    }
}

// MARK: Remembers Id

public extension CredentialsManager {
    
    @discardableResult
    func setRemembersId(_ remembers: Bool) -> Bool {
        guard let remembersIdData = String(remembers).data(using: .utf8) else { return false }
        return keychainManager.set(remembersIdData, forKey: rememberIdKey, withAccessibility: .whenPasscodeSetThisDeviceOnly)
    }
    
    var remembersId: Bool? {
        guard let string = keychainManager.string(forKey: rememberIdKey, withAccessibility: .whenPasscodeSetThisDeviceOnly) else {
            return nil
        }
        return string == "true"
    }
}
