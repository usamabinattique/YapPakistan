//
//  TransactionFilter.swift
//  YAPPakistan
//
//  Created by Umair  on 23/12/2021.
//

import Foundation

public struct TransactionFilter {
    public var minAmount: Double
    public var maxAmount: Double
    public var maxAllowedAmount: Double
    public var retail: Bool
    public var online: Bool
    public var atmWidrawl: Bool
    
    public init() {
        minAmount = -1
        maxAmount = -1
        retail = false
        online = false
        atmWidrawl = false
        maxAllowedAmount = 0
    }
    
    mutating public func assignValueAcordingToFilterType(type:TransactionFilterType ,value:Bool){
        switch type {
        case .retailPayment:
            retail = value
        case .onlineTransactions:
            online = value
        case .atmWithdrawl:
            atmWidrawl = value
        }
    }
}

public extension TransactionFilter {
    
    func getFiltersCount() -> Int {
        var count = [retail, online, atmWidrawl].filter{ $0 }.count
        count +=  (minAmount < 0 || maxAmount < 0) || maxAllowedAmount == maxAmount ? 0 : 1
        
        return count
    }
}
