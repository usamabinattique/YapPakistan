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
