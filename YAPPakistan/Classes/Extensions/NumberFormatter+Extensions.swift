//
//  NumberFormatter+Extensions.swift
//  YAPPakistan
//
//  Created by Umair  on 23/12/2021.
//

import Foundation

public extension NumberFormatter {
//    static func formatter(forBalance balance: Balance) -> NumberFormatter {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currencyISOCode
//        formatter.maximumFractionDigits = Int(balance.currencyDecimals) ?? 2
//        formatter.minimumFractionDigits = Int(balance.currencyDecimals) ?? 2
//        formatter.currencyCode = balance.currencyCode
//        return formatter
//    }
    
    static func formateAmount(_ amount: Double, fractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits =  fractionDigits
        formatter.minimumFractionDigits =  fractionDigits
        if let formtedAmount = formatter.string(from: NSNumber(value: amount)) {
            return formtedAmount
        }
        let format = "%0.\(fractionDigits)f"
        return String.init(format: format, amount)
    }
}
