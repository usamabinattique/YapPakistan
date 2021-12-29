//
//  Currency.swift
//  YAPKit
//
//  Created by Zain on 01/09/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation

struct Currency {
    let code: String
    let name: String
    let active: Bool
    let allowedDecimals: Int
    let isDefault: Bool
}

extension Currency: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Currency.CodingKeys.self)
        self.code = (try? container.decode(String?.self, forKey: .code)) ?? ""
        self.name = (try? container.decode(String?.self, forKey: .name)) ?? ""
        self.active = (try? container.decode(Bool?.self, forKey: .active)) ?? false
        self.allowedDecimals = (try? container.decode(Int?.self, forKey: .allowedDecimals)) ?? Int((try? container.decode(String?.self, forKey: .allowedDecimals)) ?? "2") ?? 2
        self.isDefault = (try? container.decode(Bool?.self, forKey: .isDefault)) ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case name = "name"
        case active = "active"
        case allowedDecimals = "allowedDecimalsNumber"
        case isDefault = "default"
    }
}
