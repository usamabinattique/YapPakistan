//
//  UIDevice+Extension.swift
//  YAPPakistan
//
//  Created by Sarmad on 23/09/2021.
//

import UIKit

extension UIDevice {
    static var deviceId:String { UIDevice.current.identifierForVendor?.uuidString ?? "" }
}

public extension UIDevice {
    
    /// Returns `true` if the device has a notch
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
