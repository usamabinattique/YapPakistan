//
//  NSObject+Extension.swift
//  YAPPakistan
//
//  Created by Sarmad on 17/09/2021.
//

import Foundation

public extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    static var className: String {
        return String(describing: self)
    }
}
