//
//  TransactionFilterType.swift
//  YAP
//
//  Created by Zain on 28/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public enum TransactionFilterType {
    case incoming( filter: TransactionFilter)
    case outgoing( filter: TransactionFilter)
    case young
    case household
    case categorized
    case amountRange
    case pending( filter: TransactionFilter)
    
}

extension TransactionFilterType {
    var title: String? {
        switch self {
        case .incoming:
            return "screen_transaction_filter_display_text_incoming_transactions".localized
        case .outgoing:
            return "screen_transaction_filter_display_text_outgoing_transactions".localized
        case .young:
            return "screen_transaction_filter_display_text_young_transactions".localized
        case .household:
            return "screen_transaction_filter_display_text_household_transactions".localized
        case .pending:
            return "screen_transaction_filter_display_text_pending_transactions".localized
        default:
            return nil
        }
    }
    
    var isChecked: Bool {
        switch self {
        case .incoming(let filter):
            return filter.creditSearch
        case .outgoing(let filter):
            return filter.debitSearch
        case .pending(let filter):
        return filter.pendingSearch
        default:
            return false
        }
    }
    
    static func allCases(filter:TransactionFilter)-> [Self] {
        return [.incoming(filter: filter),
                .outgoing(filter: filter),
                .pending(filter: filter)]
    }
}
