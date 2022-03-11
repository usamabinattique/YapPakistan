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

extension CustomerBalanceResponse {
    public var amount: Double {
        return currentBalance
    }
    
    public func formattedBalance(showCurrencyCode: Bool = true, shortFormat: Bool = true) -> String {
        let readable = amount.userReadable
        
        var formatted = CurrencyFormatter.format(amount: shortFormat ? readable.value : amount, in: currency)
        
        if !showCurrencyCode {
            formatted = formatted.amountFromFormattedAmount
        }
        
        if shortFormat {
            formatted += readable.denomination
        }
        
        return formatted
    }
}

// MARK: - Mocked data

public extension CustomerBalanceResponse {
    static var mock: CustomerBalanceResponse {
        CustomerBalanceResponse(currentBalance: 20000.0, currency: "PKR")
    }
}
