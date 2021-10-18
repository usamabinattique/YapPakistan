//
//  UIView+Extension.swift
//  YAPPakistan
//
//  Created by Tayyab on 04/10/2021.
//

import Foundation

public protocol ReusableView: AnyObject { }

public extension ReusableView where Self: UIView {
    static var defaultIdentifier: String {
        return String(describing: self)
    }
}
