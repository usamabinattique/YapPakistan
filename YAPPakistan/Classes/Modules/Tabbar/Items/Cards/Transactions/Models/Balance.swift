//
//  Balance.swift
//  YAP
//
//  Created by Muhammad Hussaan Saeed on 02/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
// swiftlint:disable line_length
// swiftlint:disable identifier_name

import Foundation

public struct Balance {
    public let balance: String
    public let currencyCode: String
    public let currencyDecimals: String?
    public let accountNumber: String?
}

extension Balance: Codable {
    enum CodingKeys: String, CodingKey {
        case balance = "availableBalance"
        case currencyCode = "currencyCode"
        case currencyDecimals = "currencyDecimals"
        case accountNumber = "accountNumber"
    }
}

extension Balance {
    
    public var amount: Double {
        return Double(balance) ?? 0
    }
    
    public func formattedBalance(showCurrencyCode: Bool = true, shortFormat: Bool = true) -> String {
        let readable = amount.userReadable
        
        var formatted = CurrencyFormatter.format(amount: shortFormat ? readable.value : amount, in: currencyCode)
        
        if !showCurrencyCode {
            formatted = formatted.amountFromFormattedAmount
        }
        
        if shortFormat {
            formatted += readable.denomination
        }
        
        return formatted
    }
    
    public static var defaultBalance: Balance {
        return Balance(balance: "0", currencyCode: "PKR", currencyDecimals: "2", accountNumber: "")
    }
}

// Mocked
extension Balance {
    public static var mockedBalance: Balance {
        return Balance(balance: "103456", currencyCode: "PKR", currencyDecimals: "2", accountNumber: "")
    }
}
