//
//  KeychainItemAccessibility.swift
//  Authentication
//
//  Created by Hussaan S on 25/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

protocol KeychainAttrRepresentable {
    var keychainAttrValue: CFString { get }
}

// MARK: - KeychainItemAccessibility
public enum KeychainItemAccessibility {
    /**
     The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
     
     This is recommended for items that only need to be accessible while the application is in the foreground. Items with this attribute never migrate to a new device. After a backup is restored to a new device, these items are missing. No items can be stored in this class on devices without a passcode. Disabling the device passcode causes all items in this class to be deleted.
     */
    case whenPasscodeSetThisDeviceOnly
    
    static func accessibilityForAttributeValue(_ keychainAttrValue: CFString) -> KeychainItemAccessibility? {
        for (key, value) in keychainItemAccessibilityLookup {
            if value == keychainAttrValue {
                return key
            }
        }
        
        return nil
    }
}

private let keychainItemAccessibilityLookup: [KeychainItemAccessibility: CFString] = {
    var lookup: [KeychainItemAccessibility: CFString] = [
        .whenPasscodeSetThisDeviceOnly: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
    ]
    
    return lookup
}()

extension KeychainItemAccessibility: KeychainAttrRepresentable {
    internal var keychainAttrValue: CFString {
        return keychainItemAccessibilityLookup[self]!
    }
}
