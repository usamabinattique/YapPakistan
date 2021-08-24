//
//  DenominationResponse.swift
//  Networking
//
//  Created by Wajahat Hassan on 17/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public struct DenominationResponse: Codable {
    public let amount: String
    public let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case amount
        case isActive = "active"
    }
}
