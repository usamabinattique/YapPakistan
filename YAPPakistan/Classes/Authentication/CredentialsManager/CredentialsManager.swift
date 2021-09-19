//
//  CredentialsManager.swift
//  Authentication
//
//  Created by Hussaan S on 25/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public protocol CredentialsStoreType {

    var isCredentialsAvailable: Bool { get }

    @discardableResult
    func secureCredentials(username: String, passcode: String) -> Bool
    func getUsername() -> String?
    func getPasscode(username: String) -> String?
    func secure(passcode: String) -> Bool
}

public class CredentialsManager: CredentialsStoreType {
    public var isCredentialsAvailable: Bool { false }

    public func secureCredentials(username: String, passcode: String) -> Bool {
        false
    }

    public func getUsername() -> String? {
        nil
    }

    public func getPasscode(username: String) -> String? {
        nil
    }

    public func secure(passcode: String) -> Bool {
        false
    }
<<<<<<< HEAD
    
    public func clearUsername() -> Bool {
        guard !(remembersId ?? false) else { return false }
        //return keychainManager.removeObject(forKey: usernameKey)
        return false
    }
=======
>>>>>>> 3dd81e482b81842c8bdc209b892a29c74630c4b0

}

// MARK: Remembers Id

public extension CredentialsManager {

    @discardableResult
    func setRemembersId(_ remembers: Bool) -> Bool {
        false
    }

    var remembersId: Bool? {
        nil
    }
}
