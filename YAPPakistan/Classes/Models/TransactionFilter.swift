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
    
    public var creditSearch: Bool?
    public var debitSearch: Bool?
    public var pendingSearch: Bool?
    public var yapYoungTransfer: Bool?
    public var categories:[CategoryType]?
    
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
//        case .onlineTransactions:
//            online = value
        case .atmWithdrawl:
            atmWidrawl = value
        }
    }
    
    mutating public func assignValueAcordingToFilterType(type:HomeTransactionFilterType ,value:Bool){
        switch type {
        case .incoming:
            creditSearch = value
        case .outgoing:
            debitSearch = value
        }
    }
}

public extension TransactionFilter {
    
    func getFiltersCount() -> Int {
        var count = [retail, online, atmWidrawl].filter{ $0 }.count
        count +=  (minAmount < 0 || maxAmount < 0) || maxAllowedAmount == maxAmount ? 0 : 1
        count += (debitSearch == true) ? 1 : 0
        count += (creditSearch == true) ? 1 : 0
        return count
    }
}
