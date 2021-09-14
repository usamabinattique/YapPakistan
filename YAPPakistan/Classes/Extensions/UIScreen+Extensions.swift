//
//  UIScreen+Extensions.swift
//  YAPKit
//
//  Created by Zain on 28/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public enum ScreenType {
    case iPhone5
    case iPhone6
    case iPhone6Plus
    case iPhoneX
    case iPhoneXR
}

extension UIScreen {
    public static var screenType: ScreenType {
        switch UIScreen.main.bounds.size.height {
        case 568:
            return .iPhone5
        case 667:
            return .iPhone6
        case 736:
            return .iPhone6Plus
        case 812:
            return .iPhoneX
        case 896:
            return .iPhoneXR
        default:
            return .iPhone6
        }
    }
}
