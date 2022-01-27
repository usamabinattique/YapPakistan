//
//  TransactionProductCodeFeeResponse.swift
//  YAPPakistan
//
//  Created by Yasir on 26/01/2022.
//

import Foundation

public struct TransactionProductCodeFeeResponse: Codable {
  
    public let currency: String
    public let amount: Double
    public let feeCurrency: String
    public let fixedAmount: Double

    enum CodingKeys: String, CodingKey {
        case currency
        case amount
        case feeCurrency
        case fixedAmount
    }
}

public extension TransactionProductCodeFeeResponse {
    static var mock: TransactionProductCodeFeeResponse {
        TransactionProductCodeFeeResponse(currency: "PKR", amount: 0.0, feeCurrency: "PKR", fixedAmount: 0.0)
    }
}
