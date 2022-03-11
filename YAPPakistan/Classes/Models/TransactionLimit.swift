//
//  TransactionLimit.swift
//  YAPPakistan
//
//  Created by Umair  on 11/01/2022.
//

import Foundation

public struct TransactionLimit: Codable {
    public let minLimit: String
    public let maxLimit: String
    public let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case minLimit
        case maxLimit
        case isActive = "active"
    }
}

extension TransactionLimit {
    public static var mock: TransactionLimit {
        return TransactionLimit.init(minLimit:"100", maxLimit: "100000", isActive: true)
    }
}
