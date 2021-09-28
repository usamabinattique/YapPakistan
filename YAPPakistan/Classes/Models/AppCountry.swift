//
//  Nationality.swift
//  YAPKit
//
//  Created by Zain on 19/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public struct AppCountry: Codable {
    public let countryCode: String
    public let alpha2Code: String
    public let alpha3Code: String
    public let name: String
    public let nationality: String
}

extension AppCountry {
    enum CodingKeys: String, CodingKey {
        case countryCode = "num_code"
        case alpha2Code = "alpha_2_code"
        case alpha3Code = "alpha_3_code"
        case name = "en_short_name"
        case nationality = "nationality"
    }
}
