//
//  TransactionThresholdResponse.swift
//  YAPPakistan
//
//  Created by Yasir on 26/01/2022.
//

import Foundation

public struct TransactionThresholdResponse: Codable {
    
    public let totalDebitAmount: Double
    public let dailyLimit: Double
    public let otpLimit: Double
    public let otpLimitY2Y: Double
    public let totalDebitAmountY2Y: Double
    public let totalDebitAmountTopUpSupplementary: Double
    public let dailyLimitTopUpSupplementary: Double
    
    public let otpLimitTopUpSupplementary: Double
    public let virtualCardBalanceLimit: Double
    

    enum CodingKeys: String, CodingKey {
        case totalDebitAmount
        case dailyLimit
        case otpLimit
        case otpLimitY2Y
        case totalDebitAmountY2Y
        case totalDebitAmountTopUpSupplementary
        case dailyLimitTopUpSupplementary
        case otpLimitTopUpSupplementary
        case virtualCardBalanceLimit
    }
}

public extension TransactionThresholdResponse {
    static var mock: TransactionThresholdResponse {
        TransactionThresholdResponse(totalDebitAmount: 0.0, dailyLimit: 0.0, otpLimit: 0.0, otpLimitY2Y: 0.0, totalDebitAmountY2Y: 0.0, totalDebitAmountTopUpSupplementary: 0.0, dailyLimitTopUpSupplementary: 0.0, otpLimitTopUpSupplementary: 0.0, virtualCardBalanceLimit: 0.0)
    }
}
