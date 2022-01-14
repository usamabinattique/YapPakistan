//
//  TransactionThreshold.swift
//  YAPPakistan
//
//  Created by Umair  on 10/01/2022.
//

import Foundation

public struct TransactionThreshold {
    public let totalDebitAmount: Double
    public let dailyLimit: Double
    public let remittanceOTPLimit: Double
    public let y2yOTPLimit: Double
    public let remittanceDebitAmount: Double
    public let y2yDebitAmount: Double
    public let cbwsiLimit: Double
    public let heldUAEFTSAmount: Double
    public let heldSwiftAmount: Double
    public let suplementaryTopUpDebitAmount: Double
    public let suplementaryTopUpDailyLimit: Double
    public let suplementaryTopUpOTPLimit: Double
    public let virtualCardBalanceLimit: Double
    public let holdAmountIncludedInDebitAmount: Bool
    
    enum CodingKeys: String, CodingKey {
        case totalDebitAmount = "totalDebitAmount"
        case dailyLimit = "dailyLimit"
        case remittanceOTPLimit = "otpLimit"
        case y2yOTPLimit = "otpLimitY2Y"
        case remittanceDebitAmount = "totalDebitAmountRemittance"
        case y2yDebitAmount = "totalDebitAmountY2Y"
        case cbwsiLimit = "cbwsiPaymentLimit"
        case heldUAEFTSAmount = "holdUAEFTSAmount"
        case heldSwiftAmount = "holdSwiftAmount"
        case suplementaryTopUpDebitAmount = "totalDebitAmountTopUpSupplementary"
        case suplementaryTopUpDailyLimit = "dailyLimitTopUpSupplementary"
        case suplementaryTopUpOTPLimit = "otpLimitTopUpSupplementary"
        case virtualCardBalanceLimit = "virtualCardBalanceLimit"
        case holdAmountIncludedInDebitAmount = "holdAmountIsIncludedInTotalDebitAmount"
    }
    
    
}

extension TransactionThreshold: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TransactionThreshold.CodingKeys.self)
        self.totalDebitAmount = (try? container.decode(Double?.self, forKey: .totalDebitAmount)) ?? 0
        self.dailyLimit = (try? container.decode(Double?.self, forKey: .dailyLimit)) ?? 0
        self.remittanceOTPLimit = (try? container.decode(Double?.self, forKey: .remittanceOTPLimit)) ?? 0
        self.y2yOTPLimit = (try? container.decode(Double?.self, forKey: .y2yOTPLimit)) ?? 0
        self.remittanceDebitAmount = (try? container.decode(Double?.self, forKey: .remittanceDebitAmount)) ?? 0
        self.y2yDebitAmount = (try? container.decode(Double?.self, forKey: .y2yDebitAmount)) ?? 0
        self.cbwsiLimit = (try? container.decode(Double?.self, forKey: .cbwsiLimit)) ?? 0
        self.heldUAEFTSAmount = (try? container.decode(Double?.self, forKey: .heldUAEFTSAmount)) ?? 0
        self.heldSwiftAmount = (try? container.decode(Double?.self, forKey: .heldSwiftAmount)) ?? 0
        self.suplementaryTopUpDebitAmount = (try? container.decode(Double?.self, forKey: .suplementaryTopUpDebitAmount)) ?? 0
        self.suplementaryTopUpDailyLimit = (try? container.decode(Double?.self, forKey: .suplementaryTopUpDailyLimit)) ?? 0
        self.suplementaryTopUpOTPLimit = (try? container.decode(Double?.self, forKey: .suplementaryTopUpOTPLimit)) ?? 0
        self.virtualCardBalanceLimit = (try? container.decode(Double?.self, forKey: .virtualCardBalanceLimit)) ?? 0
        self.holdAmountIncludedInDebitAmount = (try? container.decode(Bool?.self, forKey: .holdAmountIncludedInDebitAmount)) ?? false
    }
}

extension TransactionThreshold {
    private var dailyRemaining: Double { (dailyLimit - totalDebitAmount).rounded(toPlaces: 2) }
    private var remittanceRemaining: Double { (remittanceOTPLimit - remittanceDebitAmount).rounded(toPlaces: 2) }
    private var y2yRemaining: Double { (y2yOTPLimit - y2yDebitAmount).rounded(toPlaces: 2) }
    private var onHoldDailyRemaining: Double { (dailyLimit - (heldSwiftAmount + heldUAEFTSAmount)).rounded(toPlaces: 2) }
    private var onHoldOTPRemaining: Double { (remittanceOTPLimit - (heldSwiftAmount + heldUAEFTSAmount)).rounded(toPlaces: 2) }
    
    private var suplementaryTopUpDailyRemaining: Double { (suplementaryTopUpDailyLimit - suplementaryTopUpDebitAmount).rounded(toPlaces: 2) }
    private var suplementaryTopUpOTPRemaining: Double { (suplementaryTopUpOTPLimit - suplementaryTopUpDebitAmount).rounded(toPlaces: 2) }
    
    public var dailyRemainingLimit: Double { dailyRemaining < 0 ? 0 : dailyRemaining }
    public var y2yOTPRemainingLimit: Double { y2yRemaining < 0 ? 0 : y2yRemaining }
    public var remittanceOTPRemainingLimit: Double { remittanceRemaining < 0 ? 0 : remittanceRemaining }
    public var onHoldDailyRemainingLimit: Double { onHoldDailyRemaining < 0 ? 0 : onHoldDailyRemaining }
    public var onHoldOTPRemainingLimit: Double { onHoldOTPRemaining < 0 ? 0 : onHoldOTPRemaining }
    
    public var suplementaryTopUpRemainingDailyLimit: Double { suplementaryTopUpDailyRemaining < 0 ? 0 : suplementaryTopUpDailyRemaining }
    public var suplementaryTopUpRemainingOTPLimit: Double { suplementaryTopUpOTPRemaining < 0 ? 0 : suplementaryTopUpOTPRemaining }
}

public extension TransactionThreshold {
    static var empty: TransactionThreshold {
        TransactionThreshold(totalDebitAmount: 0, dailyLimit: 0, remittanceOTPLimit: 0, y2yOTPLimit: 0, remittanceDebitAmount: 0, y2yDebitAmount: 0, cbwsiLimit: 0, heldUAEFTSAmount: 0, heldSwiftAmount: 0, suplementaryTopUpDebitAmount: 0, suplementaryTopUpDailyLimit: 0, suplementaryTopUpOTPLimit: 0, virtualCardBalanceLimit: 0, holdAmountIncludedInDebitAmount: false)
    }
    
    static var mock: TransactionThreshold {
        TransactionThreshold(totalDebitAmount: 10, dailyLimit: 1000000000, remittanceOTPLimit: 10000, y2yOTPLimit: 10000, remittanceDebitAmount: 10000, y2yDebitAmount: 1000, cbwsiLimit: 1000, heldUAEFTSAmount: 1000, heldSwiftAmount: 1000, suplementaryTopUpDebitAmount: 1000, suplementaryTopUpDailyLimit: 1000, suplementaryTopUpOTPLimit: 1000, virtualCardBalanceLimit: 50000, holdAmountIncludedInDebitAmount: false)
    }
}
