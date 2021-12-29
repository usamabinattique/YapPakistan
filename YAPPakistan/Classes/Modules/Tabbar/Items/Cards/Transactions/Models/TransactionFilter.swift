//
//  TransactionFilter.swift
//  YAP
//
//  Created by Wajahat Hassan on 21/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public struct TransactionFilter {
    public var minAmount: Double
    public var maxAmount: Double
    public var maxAllowedAmount: Double
    public var creditSearch: Bool
    public var debitSearch: Bool
    public var pendingSearch: Bool
    public var yapYoungTransfer: Bool
    public var categories:[CategoryType]

    public init() {
        minAmount = -1
        maxAmount = -1
        creditSearch = false
        debitSearch = false
        yapYoungTransfer = true
        pendingSearch = false
        categories = [CategoryType]()
        maxAllowedAmount = 0
    }

    mutating public func assignValueAcordingToFilterType(type: TransactionFilterType ,value: Bool){
        switch type {
        case .incoming:
            creditSearch = value
        case .outgoing:
            debitSearch = value
        case .pending:
            pendingSearch = value
        default:
            yapYoungTransfer = value
        }
    }
}

public extension TransactionFilter {

    func getFiltersCount() -> Int {
        var count = [creditSearch, debitSearch, pendingSearch].filter{ $0 }.count
        count += categories.count > 0 ? 1 : 0
        count +=  (minAmount < 0 || maxAmount < 0) || maxAllowedAmount == maxAmount ? 0 : 1

        return count
    }
}
