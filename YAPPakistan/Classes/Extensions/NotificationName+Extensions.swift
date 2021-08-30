//
//  NotificationName+Extensions.swift
//  YAPKit
//
//  Created by Zain on 14/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation

public extension Notification.Name {
    static let applicationWillResignActive = Notification.Name("applicationWillResignActive")
    static let applicationDidBecomeActive = Notification.Name("applicationDidBecomeActive")
    static let applicationWillEnterForeground = Notification.Name("applicationWillEnterForeground")
}
