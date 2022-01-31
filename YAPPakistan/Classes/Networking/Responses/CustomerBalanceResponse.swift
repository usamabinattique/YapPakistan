//
//  CustomerBalanceResponse.swift
//  YAPPakistan
//
//  Created by Yasir on 26/01/2022.
//

import Foundation

public struct CustomerBalanceResponse: Codable {
    public let currentBalance: Double
    public let currency: String

    enum CodingKeys: String, CodingKey {
        case currentBalance
        case currency 
    }
}

// MARK: - Mocked data

public extension CustomerBalanceResponse {
    static var mock: CustomerBalanceResponse {
        CustomerBalanceResponse(currentBalance: 0.0, currency: "0.0")
    }
}
