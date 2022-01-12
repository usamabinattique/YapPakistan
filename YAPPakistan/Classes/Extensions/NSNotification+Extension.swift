//
//  NSNotification+Extension.swift
//  YAPPakistan_Example
//
//  Created by Yasir on 12/01/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

public extension NSNotification.Name{
    
    enum YapPakistanBadgeNotification: String {
        case logout = "com.yap.logout"
        case authenticationRequired = "com.yap.authenticationRequired"
    }
    
    init(_ value: YapPakistanBadgeNotification) {
        self = NSNotification.Name(value.rawValue)
    }
}
