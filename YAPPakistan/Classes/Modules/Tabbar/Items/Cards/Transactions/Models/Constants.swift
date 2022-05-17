//
//  Constants.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 17/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
// swiftlint:disable line_length
// swiftlint:disable identifier_name

import Foundation


public enum TransactionProductCode: String, Codable {
    case y2yTransfer = "P003"
    case removeFundsSuplementaryCard = "P004"
    case debitCardReorder = "P005"
    case addFundsSupplementaryCard = "P006"
    case topUpByExternalCard = "P009"
    case uaeftsTransfer = "P010"
    case swift = "P011"
    case rmt = "P012"
    case cashPayout = "P013"
    case manualAdjustment = "P014"
    case feeDeduct = "P015"
    case fundLoad = "P016"
    case fundWithdrawl = "P017"
    case atmWithdrawl = "P018"
    case posPurchase = "P019"
    case fssFundsWithdrawl = "P020"
    case virtualCardIssuanceFee = "P021"
    case physicalCardIssuanceFee = "P022"
    case domestic = "P023"
    case cashDepositInBank = "P024"
    case chequeDepositInBank = "P025"
    case inwardRemittance = "P026"
    case localInwardRemittance = "P027"
    case fundsWithdrawlByCheque = "P028"
    case masterCardATMWithdrawl = "P029"
    case masterCardReversal = "P030"
    case masterCardRefund = "P031"
    case transactionReversal = "P032"
    case cashAdvance = "P033"
    case atmDeposit = "P034"
    case moto = "P035"
    case eCom = "P036"
    case balanceInquiry = "P037"
    case miniStatement = "P038"
    case pinChange = "P039"
    case accountStatusInquiry = "P040"
    case paymentTransaction = "P041"
    case fssFeeNotification = "P042"
    case ibftTransaction = "P044-out"
    case unknown
}

public extension TransactionProductCode {
    var isCash: Bool {
        [.cashPayout, .atmWithdrawl, .atmDeposit, .masterCardATMWithdrawl, .cashAdvance, .fundWithdrawl, .fundsWithdrawlByCheque].contains(self)
    }
    
    var isBank: Bool {
        [.uaeftsTransfer, .domestic, .rmt, .swift, .paymentTransaction, .moto, .eCom].contains(self)
    }
    
    var isIncoming: Bool {
        [.inwardRemittance, .localInwardRemittance, .fundLoad].contains(self)
    }
    
    var isFee: Bool {
        [.manualAdjustment, .virtualCardIssuanceFee, .fssFundsWithdrawl, .debitCardReorder, .feeDeduct, .physicalCardIssuanceFee, .balanceInquiry, .pinChange, .miniStatement, .accountStatusInquiry, .fssFeeNotification].contains(self)
    }
    
    var isRefund: Bool {
        [.masterCardRefund, .masterCardReversal, .transactionReversal].contains(self)
    }
    
    var isSendMoney: Bool {
        [.uaeftsTransfer, .domestic, .rmt, .swift].contains(self)
    }
    
    var addRemoveFunds: Bool {
        [.removeFundsSuplementaryCard, .addFundsSupplementaryCard].contains(self)
    }
    
    var isForReceipt: Bool {
        [.atmWithdrawl, .atmDeposit, .posPurchase].contains(self)
    }
    
    var isValidForTotalPurchase: Bool {
        [.atmWithdrawl, .eCom, .rmt, .swift, .uaeftsTransfer, .posPurchase, .y2yTransfer, .domestic].contains(self)
    }
    
    var shouldDisplayCategory: Bool {
        [.eCom, .posPurchase].contains(self)
    }
    
    var shouldDisplayImproveAttributes: Bool {
        [.eCom, .posPurchase, .atmDeposit, .atmWithdrawl].contains(self)
    }
    
    var hideFeeAndVat: Bool {
        [.eCom, .posPurchase, .atmDeposit, .atmWithdrawl].contains(self)
    }
    
}

public extension TransactionProductCode {
    init(from decoder: Decoder) throws {
        self = try TransactionProductCode(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public extension TransactionProductCode {
    var localized: String {
        switch self {
        case .y2yTransfer:
            return "Y2Y_TRANSFER"
        case .removeFundsSuplementaryCard:
            return "WITHDRAW"
        case .debitCardReorder:
            return "CARD_REORDER"
        case .addFundsSupplementaryCard:
            return "SUPPLEMENTARY_CARD"
        case .topUpByExternalCard:
            return "TOP_UP_VIA_CARD"
        case .uaeftsTransfer:
            return "UAEFTS"
        case .swift:
            return "SWIFT"
        case .rmt:
            return "RMT"
        case .cashPayout:
            return "CASH_PAYOUT"
        case .manualAdjustment:
            return "MANUAL_ADJUSTMENT"
        case .feeDeduct:
            return "FEE_DEDUCT"
        case .fundLoad:
            return "FUND_LOAD"
        case .fundWithdrawl:
            return "FUND_WITHDRAWAL"
        case .atmWithdrawl:
            return "ATM_WITHDRAW"
        case .posPurchase:
            return "POS_PURCHASE"
        case .fssFundsWithdrawl:
            return "FSS_FUND_WITHDRAWAL"
        case .virtualCardIssuanceFee:
            return "VIRTUAL_ISSUANCE_FEE"
        case .physicalCardIssuanceFee:
            return "PHYSICAL_ISSUANCE_FEE"
        case .domestic:
            return "DOMESTIC"
        case .cashDepositInBank:
            return "CASH_DEPOSIT_AT_RAK"
        case .chequeDepositInBank:
            return "CHEQUE_DEPOSIT_AT_RAK"
        case .inwardRemittance:
            return "INWARD_REMITTANCE"
        case .localInwardRemittance:
            return "LOCAL_INWARD_TRANSFER"
        case .fundsWithdrawlByCheque:
            return "FUNDS_WITHDRAWAL_BY_CHEQUE"
        case .masterCardATMWithdrawl:
            return "MASTER_CARD_ATM_WITHDRAWAL"
        case .masterCardReversal:
            return "REVERSAL_MASTER_CARD"
        case .masterCardRefund:
            return "REFUND_MASTER_CARD"
        case .transactionReversal:
            return "REVERSAL_OF_TXN_ON_FAILURE"
        case .cashAdvance:
            return "CASH_ADVANCE"
        case .atmDeposit:
            return "ATM_DEPOSIT"
        case .moto:
            return "MOTO"
        case .eCom:
            return "ECOM"
        case .balanceInquiry:
            return "BALANCE_INQUIRY"
        case .miniStatement:
            return "MINISTATEMENT"
        case .pinChange:
            return "PIN_CHANGE"
        case .accountStatusInquiry:
            return "ACCOUNT_STATUS_INQUIRY"
        case .paymentTransaction:
            return "PAYMENT_TRANSACTION"
        case .fssFeeNotification:
            return "FSS_FEE_NOTIFICATION"
        case .ibftTransaction:
            return "P044-out"
        case .unknown:
            return ""
        }
    }
    
    func icon(forTransactionType transactionType: TransactionType?, transactionStatus: TransactionStatus) -> UIImage? {
        
        guard transactionStatus == .completed || transactionStatus == .inProgress || transactionStatus == .pending || transactionStatus == .cancelled || transactionStatus == .failed else {
            return UIImage.init(named: "icon_delayed_transfer", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        }
        
        guard transactionStatus != .cancelled && transactionStatus != .failed  else {
            return UIImage.init(named: "icon_cancelled_transaction", in: .yapPakistan, compatibleWith: nil)
        }
        
        guard !isBank else { return UIImage.init(named: "icon_trans_send_money", in: .yapPakistan, compatibleWith: nil)?.asTemplate }
        
        guard !isCash else { return UIImage.init(named: "icon_cash_payout", in: .yapPakistan, compatibleWith: nil)?.asTemplate }
        
        guard !isRefund else { return UIImage.init(named: "icon_refund_transaction", in: .yapPakistan, compatibleWith: nil)?.asTemplate }
        
        guard !isFee else { return UIImage.init(named: "icon_transaction_fee", in: .yapPakistan, compatibleWith: nil) }
        
        guard !isIncoming else { return UIImage.init(named: "icon_incoming_transaction", in: .yapPakistan, compatibleWith: nil) }
        
        switch self {
            
        case .y2yTransfer:
            return UIImage.init(named: "icon_y2y_transfer", in: .yapPakistan, compatibleWith: nil)?.asTemplate
            
        case .addFundsSupplementaryCard, .removeFundsSuplementaryCard:
            return UIImage.init(named: "icon_add_remove_funds_purple", in: .yapPakistan)
            
        default:
            return nil
        }
    }
}

public enum TransactionStatus: String {
    case pending = "PENDING"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case failed = "FAILED"
    case cancelled = "CANCELLED"
    case none = "NONE"
}

public enum DashboardResult {
    case logout
    case switchAccount
    case none
}

//var isHouseholdEnabled: Bool {
//    return Bundle.main.environment == .household
//}



