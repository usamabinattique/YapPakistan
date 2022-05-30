//
//  CurrencyFormatter.swift
//  YAPKit
//
//  Created by Muhammad Hassan on 08/04/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation

var localeNumberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = .current
    return numberFormatter
}()

enum CurrencyType: String {
    case aed = "AED"
    case pkr = "PKR"
}

class CurrencyFormatter {
    static var currencies: [Currency] = []
    
    static func format(amount: Double, in currency: CurrencyType) -> String {
        format(amount: amount, in: currency.rawValue)
    }
    
    static func format(amount: Double, in currency: String) -> String {
        "\(currency) \(NumberFormatter.formateAmount(amount.rounded(toPlaces: decimalPlaces(for: currency)), fractionDigits: decimalPlaces(for: currency)))"
    }
    
    static func format(amount: String, in currency: CurrencyType) -> String? {
        amount.split(separator: " ")
            .filter { Double($0) != nil }
            .first.flatMap { Double($0) }
            .map { format(amount: $0, in: currency.rawValue) }
    }
    
    static func formatAmountInLocalCurrency(_ amount: Double) -> String {
        format(amount: amount, in: .pkr)
    }
    
    static var defaultFormattedFee: String {
        formatAmountInLocalCurrency(0)
    }
    
    static func decimalPlaces(for currency: String) -> Int {
        currencies.filter{ $0.code == currency }.first?.allowedDecimals ?? 0
    }
    
    static func amountString(for currency: String, _ amount: Double) -> String {
        NumberFormatter.formateAmount(amount, fractionDigits: decimalPlaces(for: currency))
            .removingGroupingSeparator()
            .replacingOccurrences(of: localeNumberFormatter.currencyDecimalSeparator, with: ".")
    }
}

extension String {
    var amountFromFormattedAmount: String { components(separatedBy: " ").last ?? "" }
    var currencyFromFormattedAmount: String? { components(separatedBy: " ").first }
}
