//
//  TransferFee.swift
//  YAPPakistan
//
//  Created by Umair  on 10/01/2022.
//

import Foundation

public enum TransferFeeType: String, Codable {
    case tier = "TIER"
    case flat = "FLAT"
}

public struct TransferFeeTier {
    let amountFrom: Double
    let amountTo: Double
    let feeAmount: Double
    let feePercentage: Double
    let vatPercentage: Double
    public let feeInPercentage: Bool
}

extension TransferFeeTier: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TransferFeeTier.CodingKeys.self)
        self.amountFrom = (try? container.decode(Double?.self, forKey: .amountFrom)) ?? 0
        self.amountTo = (try? container.decode(Double?.self, forKey: .amountTo)) ?? 0
        self.feeAmount = (try? container.decode(Double?.self, forKey: .feeAmount)) ?? 0
        self.feePercentage = (try? container.decode(Double?.self, forKey: .feePercentage)) ?? 0
        self.vatPercentage = (try? container.decode(Double?.self, forKey: .vatPercentage)) ?? 0
        self.feeInPercentage = (try? container.decode(Bool?.self, forKey: .feeInPercentage)) ?? false
    }
}

public extension TransferFeeTier {
    static func mocked(from: Double, to: Double, fee: Double, vatAmount: Double, feePercentage: Double, vatPercentage: Double, feeInPercentage: Bool) -> TransferFeeTier {
        TransferFeeTier(amountFrom: from, amountTo: to, feeAmount: fee, feePercentage: feePercentage, vatPercentage: vatPercentage, feeInPercentage: feeInPercentage)
    }
}

public struct TransferFee {
    public let feeType: TransferFeeType
    public let tiers: [TransferFeeTier]
    public let fixedAmount: Double
    public let slabCurrency: String
    public let feeCurrency: String
    
    public init(feeType: TransferFeeType, fixedAmount: Double, slabCurrency: String, feeCurrency: String, tiers: [TransferFeeTier]) {
        self.feeType = feeType
        self.tiers = tiers
        self.fixedAmount = fixedAmount
        self.slabCurrency = slabCurrency
        self.feeCurrency = feeCurrency
    }
}

extension TransferFee: Codable {
    
    enum CodingKeys: String, CodingKey {
        case feeType = "feeType"
        case tiers = "tierRateDTOList"
        case fixedAmount = "fixedAmount"
        case slabCurrency = "slabCurrency"
        case feeCurrency = "feeCurrency"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TransferFee.CodingKeys.self)
        self.feeType = (try? container.decode(TransferFeeType?.self, forKey: .feeType)) ?? .flat
        self.tiers = (try? container.decode([TransferFeeTier]?.self, forKey: .tiers)) ?? []
        self.fixedAmount = (try? container.decode(Double?.self, forKey: .fixedAmount)) ?? 0
        self.slabCurrency = (try? container.decode(String?.self, forKey: .slabCurrency)) ?? "PKR"
        self.feeCurrency = (try? container.decode(String?.self, forKey: .feeCurrency)) ?? "PKR"
    }
}


// MARK: - Fee calculations

private extension TransferFee {
    func getFee(for amount: Double, from tier: TransferFeeTier, exchnageRate: Double) -> Double {
        
        var fee = !tier.feeInPercentage ? tier.feeAmount : ((amount * tier.feePercentage) / 100)
        
        if !tier.feeInPercentage {
            fee = feeCurrency == "AED" ? fee : fee * exchnageRate
        } else {
            fee = slabCurrency == "AED" ? fee : fee * exchnageRate
        }
        
        return (fee + fixedAmount).rounded(toPlaces: 2)
    }
    
    func getVat(for fee: Double, from tier: TransferFeeTier) -> Double {
        ((fee * tier.vatPercentage) / 100).rounded(toPlaces: 2)
    }
}

// MARK: - Fee methods

public extension TransferFee {
    
    var flatVATAmount: Double {
        (flatFeeAmount * (tiers.first?.vatPercentage ?? 0)) / 100.0
    }
    
    var flatFeeAmount: Double {
        (tiers.first?.feeAmount ?? 0) + fixedAmount
    }
    
    var flatTaxedFeeAmount: Double? {
        flatFeeAmount + flatVATAmount
    }
    
    func getTaxedFee(for amount: Double, exchnageRate: Double = 1.0) -> Double {
        let fee = getFee(for: amount, exchnageRate: exchnageRate)
        let vat = getVat(for: fee, amount: amount)
        return  fee + vat
    }
    
    func getFee(for amount: Double, exchnageRate: Double = 1.0) -> Double {
        guard let tier = feeType == .flat ?
            tiers.first : tiers.filter({ $0.amountFrom...$0.amountTo ~= amount }).first
            else { return 0 }
        return getFee(for: amount, from: tier, exchnageRate: exchnageRate)
    }
    
    func getVat(for fee: Double, amount: Double) -> Double {
        guard let tier = feeType == .flat ?
            tiers.first : tiers.filter({ $0.amountFrom...$0.amountTo ~= amount }).first
            else { return 0 }
        
        return getVat(for: fee, from: tier)
    }
    
    func getFeeCharges(for amount: Double, exchangeRate: Double = 1.0) -> (fee: Double, vat: Double) {
        let fee = getFee(for: amount, exchnageRate: exchangeRate)
        let vat = getVat(for: fee, amount: amount)
        return (fee, vat)
    }
    
    func getFormattedFee(for amount: Double) -> String? {
        CurrencyFormatter.formatAmountInLocalCurrency(getTaxedFee(for: amount))
    }
}

// MARK: - Mocked data

public extension TransferFee {
    static var mock: TransferFee {
        TransferFee(feeType: TransferFeeType.flat, fixedAmount: 0, slabCurrency: "AED", feeCurrency: "AED", tiers: [TransferFeeTier.mocked(from: 0, to: 0, fee: 0, vatAmount: 0, feePercentage: 0, vatPercentage: 0, feeInPercentage: false)])
    }
}
