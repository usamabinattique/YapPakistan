//
//  TransactionProductCodeFeeResponse.swift
//  YAPPakistan
//
//  Created by Yasir on 26/01/2022.
//

import Foundation

public struct TransactionProductCodeFeeResponse: Codable {
    
    public let feeType: String
    public let amount: Int?
    public let feeCurrency: String?
    public let displayOnly: Bool
    public let fixedAmount: Double?
//    public let tierRateDTOList: Array?
    
    enum CodingKeys: String, CodingKey {
        case feeType
        case amount
        case feeCurrency
        case displayOnly
        case fixedAmount
//        case tierRateDTOList
    }
}

public extension TransactionProductCodeFeeResponse {
    static var mock: TransactionProductCodeFeeResponse {
        TransactionProductCodeFeeResponse(feeType: "FLAT", amount: 0, feeCurrency: "PKR", displayOnly: false, fixedAmount: 3.6)
    }
}
