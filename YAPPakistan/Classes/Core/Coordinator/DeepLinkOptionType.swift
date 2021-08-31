//
//  DeepLinkOptionType.swift
//  YAPMVVMC
//
//  Created by Sarmad on 27/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

public protocol DeepLinkOptionType {
    static func build(with userActivity: NSUserActivity) -> Self?
    static func build(with dict: [String : AnyObject]?) -> Self?
}

