//
//  AppTranslation.swift
//  AppTranslation
//
//  Created by Zain on 17/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public class AppTranslation {
    public static let shared = AppTranslation()
    private init () { }
    public func translation(forKey key: String, comment: String = "") -> String {
        return translationBundel.localizedString(forKey: key, value: nil, table: nil)
    }
}



var translationBundel: Bundle {
    return Bundle(for: AppTranslation.self)
}

