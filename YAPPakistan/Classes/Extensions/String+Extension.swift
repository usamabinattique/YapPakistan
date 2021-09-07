//
//  String+Extension.swift
//  YAPPakistan
//
//  Created by Umer on 07/09/2021.
//

import Foundation

private class YAPPakistanBundle {
    static var bundle: Bundle {
        Bundle(for: self)
    }
}

public extension String {
    var localized: String {
        #if DEBUG
            return YAPPakistanBundle.bundle.localizedString(forKey: self, value: "**\(self)**", table: nil)
        #else
            return YAPPakistanBundle.bundle.localizedString(forKey: self, value: nil, table: nil)
        #endif
    }
}
