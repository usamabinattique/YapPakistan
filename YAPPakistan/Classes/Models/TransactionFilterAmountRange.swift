//
//  TransactionFilterAmountRange.swift
//  YAPPakistan
//
//  Created by Umair  on 30/12/2021.
//

import Foundation

public struct TransactionFilterAmountRange: Codable {
    public let minAmount: Double
    public let maxAmount: Double
}
