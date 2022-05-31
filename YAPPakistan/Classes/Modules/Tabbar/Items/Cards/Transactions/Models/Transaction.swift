//
//  Transaction.swift
//  YAPKit
//
//  Created by Muhammad Hassan on 26/01/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation

protocol Transaction {
    var id: Int { get }
    var title: String? { get }
    var type: TransactionType { get }
    var date: Date { get }
    var status: String? { get }
    var currency: String? { get }
    var amount: Double { get }
    var totalAmount: Double? { get }
    var productCode: TransactionProductCode { get }
    var receiverName: String? { get }
    var maskedCardNumber: String? { get }
    var senderName: String? { get }
    var category: String { get }
    var location: String? { get }
    var merchantName: String? { get }
    var fee: Double { get }
    var vat: Double { get }
    var settlementAmount: Double { get }
    var index: Int? { get }
    var otherBankName: String? { get }
    var cardName1: String? { get }
    var cardName2: String? { get }
    var merchant: String? { get }
    var cardType: String? { get }
    var transactionState: TransactionState? { get }
    var cardHolderBillingAmount: Double { get }
    var cardHolderBillingCurrency: String? { get }
    var cardHolderBillingTotalAmount: Double { get }
    
    var customerId1: String? { get }
    var customerId2: String? { get }
}

extension Transaction {
    var prepaidCardName: String? {
        return cardType == "PREPAID" ? cardName1 : cardName2
    }
    
    var finalizedTitle: String? {
        switch productCode {
        case .domestic, .rmt, .swift, .uaeftsTransfer, .cashPayout, .y2yTransfer:
            return type == .debit ? (receiverName == nil ? nil :"Sent to \(receiverName!)") : type == .credit ? (senderName == nil ? nil :"Received from \(senderName!)") : nil ?? title
        case .topUpByExternalCard:
            guard let last4digit = maskedCardNumber?.suffix(4) else { return title }
//            return "Top up via *\(last4digit)"
            return "Top up"
        case .addFundsSupplementaryCard:
            return prepaidCardName.map { "Add to \($0)" } ?? "Add to Virtual Card"
        case .removeFundsSuplementaryCard:
            return prepaidCardName.map { "Remove from \($0)" } ?? "Remove from Virtual Card"
        case .posPurchase, .eCom:
            return merchantName.map { "\($0)" }
        case .atmDeposit:
            return "Cash deposit"
        case .atmWithdrawl:
            return "ATM Withdrawal"
        case .fundLoad:
            if let sender = self.senderName {
                return "Received from " + sender
            } else {
                return "Received transfer"
            }
        default:
            return title
        }
    }
    
    var formattedTime: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        return timeFormatter.string(from: date)
    }
    
    var unwrappedStatus: TransactionStatus { TransactionStatus.init(rawValue: status ?? "") ?? .none }
    
    var transferType: String {
        if productCode.isFee {
            return "Fee"
        }
        
        if productCode.isRefund {
            return "Refund"
        }
        
        if unwrappedStatus == .cancelled {
            return "Transfer rejected"
        }
        
        switch productCode {
        case .domestic, .rmt, .swift, .uaeftsTransfer, .cashPayout:
            return "Send money"
        case .y2yTransfer:
            return "YTY"
        case .atmWithdrawl, .masterCardATMWithdrawl , .fundWithdrawl:
            return category == "REVERSAL" ? "Reversal" : "Withdraw money"
        case .fundLoad, .inwardRemittance, .localInwardRemittance:
            return category == "REVERSAL" ? "Reversal" : "Inward bank transfer"
        case  .atmDeposit, .cashDepositInBank, .chequeDepositInBank:
            return category == "REVERSAL" ? "Reversal" : "Deposit"
        case .posPurchase:
            return "In store shopping"
        case .eCom:
            return "Online shopping"
        case .topUpByExternalCard:
            return "Add money"
        case .removeFundsSuplementaryCard:
            return "Money moved"
        case .addFundsSupplementaryCard:
            return "Money moved"
        default:
            return "Transaction"
        }
    }
    
    var detailTransferType: String {
        if isTransactionInProgress { return "Transfer pending" }
        
        if unwrappedStatus == .cancelled || unwrappedStatus == .failed {
            return "Transfer rejected"
        }
        
        if productCode == .y2yTransfer { return "YAP to YAP transfer" }
        return transferType
    }
    
    var finalizedStatus: String {
        if productCode == .atmWithdrawl || productCode == .atmDeposit { return location ?? "" }
        
        if productCode == .fundLoad { return otherBankName ?? "" }
        
        if productCode.isFee { return "" }
        
        if isTransactionInProgress { return "Transaction in process" }
        
        switch unwrappedStatus {
        case .failed:
            return "Rejected transaction"
        case .cancelled:
            return "Cancelled transaction"
        default:
            return ""
        }
    }
    
    var calculatedTotalAmount: Double {
        //        guard productCode != .rmt && productCode != .swift else {
        //            return settlementAmount + vat + fee
        //        }
        guard type == .credit else { return totalAmount ?? 0.00 }
        return amount
    }
    
    var color: UIColor { .green } /// UIColor.colorFor(listItemIndex: index ?? 0)
    
    var icon: String? {
        guard unwrappedStatus == .completed || unwrappedStatus == .inProgress || unwrappedStatus == .pending || unwrappedStatus == .cancelled || unwrappedStatus == .failed else {
            return "icon_delayed_transfer"
        }
        
        guard unwrappedStatus != .cancelled && unwrappedStatus != .failed  else {
            return "icon_cancelled_transaction"
        }
        
        if productCode.isBank {
            return "icon_trans_send_money"
        }
        
        if productCode == .virtualCardIssuanceFee {
            return "icon_virtual_card_issuance_fee"
        }
        
        if productCode == .addFundsSupplementaryCard ||
            productCode == .removeFundsSuplementaryCard {
            return "icon_virtual_card_transaction"
        }
        
        guard !productCode.isIncoming else { return "icon_trans_send_money" }
        
        guard !productCode.isCash else { return "icon_cash_payout" }
        
        guard !productCode.isRefund else { return "icon_refund_transaction" }
        
        guard !productCode.isFee else { return "icon_transaction_fee" }
        
        switch productCode {
        case .addFundsSupplementaryCard, .removeFundsSuplementaryCard:
            return "icon_transaction_fee"
        case .topUpByExternalCard:
            return "icon_card_transfer"
        case .cashDepositInBank, .chequeDepositInBank:
            return "icon_incoming_transaction"
        default:
            return nil
        }
    }
    
    var statusIcon: String? {
        guard unwrappedStatus != .failed && unwrappedStatus != .cancelled else { return nil }
        if productCode.isFee { return nil }
        guard !isTransactionInProgress else { return  "icon_transaction_type_inprogress" }
        
        switch productCode {
        case .atmWithdrawl, .fundsWithdrawlByCheque, .fundWithdrawl, .removeFundsSuplementaryCard:
            return "icon_identifire_atm_withdrawal"
        case .atmDeposit, .topUpByExternalCard, .addFundsSupplementaryCard:
            return "icon_identifire_atm_deposit"
        case .y2yTransfer, .cashPayout, .rmt, .swift, .uaeftsTransfer, .domestic:
            if type == .debit {
                return "icon_transaction_type_debit"
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    var isTransactionInProgress: Bool {
        if unwrappedStatus == .inProgress &&
            (productCode == .swift || productCode == .uaeftsTransfer) &&
            transactionState?.isInProgress ?? false {
            return true
        }
        return false
    }
}
