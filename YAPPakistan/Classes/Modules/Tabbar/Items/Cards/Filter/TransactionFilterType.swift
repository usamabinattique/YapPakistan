//
//  TransactionFilterType.swift
//  YAPPakistan
//
//  Created by Umair  on 22/12/2021.
//

import Foundation

public enum TransactionFilterType {
    case retailPayment ( filter: TransactionFilter)
    case onlineTransactions ( filter: TransactionFilter)
    case atmWithdrawl ( filter: TransactionFilter)
}

extension TransactionFilterType {
    var title: String? {
        switch self {
        case .retailPayment:
            return "screen_transaction_filter_display_text_retail_payments".localized
        case .onlineTransactions:
            return "screen_transaction_filter_display_text_online_transactions".localized
        case .atmWithdrawl:
            return "screen_transaction_filter_display_text_atm_withdrawl".localized
        }
    }
    
    var isChecked: Bool {
//        switch self {
//        case .retailPayment(let filter):
//            return filter.creditSearch
//        case .onlineTransactions(let filter):
//            return filter.debitSearch
//        case .atmWithdrawl(let filter):
//        return filter.pendingSearch
//        default:
//            return false
//        }
        return false
    }
    
    static func allCases(filter:TransactionFilter)-> [Self] {
        return [.retailPayment(filter: filter),
                .onlineTransactions(filter: filter),
                .atmWithdrawl(filter: filter)]
    }
}
