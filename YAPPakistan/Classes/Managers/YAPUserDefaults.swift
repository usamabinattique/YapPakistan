//
//  YAPUserDefaults.swift
//  YAPKit
//
//  Created by Ahmer Hassan on 26/03/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation

public class YAPUserDefaults {

    public static func turnNotificationOn(preference: Bool) {
        let defaults = UserDefaults.standard
        defaults.setValue(preference, forKey: "isNotificationOn")
    }
    public static func isNotificationOn() -> Bool{
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "isNotificationOn")
    }

    public static func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
