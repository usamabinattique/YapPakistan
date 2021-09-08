//
//  String+Extension.swift
//  YAPPakistan
//
//  Created by Umer on 07/09/2021.
//

import Foundation

public extension String {
    var localized: String {
        #if DEBUG
            return Bundle.yapPakistan.localizedString(forKey: self, value: "**\(self)**", table: nil)
        #else
            return Bundle.yapPakistan.localizedString(forKey: self, value: nil, table: nil)
        #endif
    }
}