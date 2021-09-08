//
//  CountryFlag.swift
//  YAPKit
//
//  Created by Zain on 24/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit

public class CountryFlag {
    public static func flag(forCountryCode countryCode: String) -> UIImage? {
        return UIImage.init(named: countryCode.uppercased(), in: .yapPakistan, compatibleWith: nil)
    }
}
