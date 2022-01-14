//
//  TransactionLimit.swift
//  YAPPakistan
//
//  Created by Umair  on 11/01/2022.
//

import Foundation

public struct TransactionLimit: Codable {
    public let min: String
    public let max: String
    public let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case min = "minLimit"
        case max = "maxLimit"
        case isActive = "active"
    }
}

extension TransactionLimit {
    public static var mock: TransactionLimit {
        return TransactionLimit.init(min: "100", max: "100000", isActive: true)
    }
}
