//
//  TransactionDetailsAmountInfoCellViewModel.swift
//  YAP
//
//  Created by Wajahat Hassan on 28/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents

class TransactionDetailsAmountInfoCellViewModel: ReusableTableViewCellViewModelType {
    
    let disposeBag = DisposeBag()
    var reusableIdentifier: String { return TransactionDetailsAmountInfoCell.defaultIdentifier }
    
    private let cardValueSubject: BehaviorSubject<String?>
    private let userHeadingSubject: BehaviorSubject<String?>
    private let userValueSubject: BehaviorSubject<String?>
    private let amountHeadingSubject: BehaviorSubject<String?>
    private let amountValueSubject: BehaviorSubject<String?>
    private let feeValueSubject =  BehaviorSubject<String?>(value: nil)
    private let vatValueSubject: BehaviorSubject<String?>
    private let totalAmountValueSubject: BehaviorSubject<String?>
    private let cancelReasonSubject: BehaviorSubject<String?>
    private let referenceNumberSubject: BehaviorSubject<String?>
    private let foreignAmountHeadingSubject: BehaviorSubject<String?>
    private let foreignAmountValueSubject: BehaviorSubject<String?>
    private let exchangeRateValueSubject: BehaviorSubject<String?>
    private let remarksSubject: BehaviorSubject<String?>
    private let isHidePaymentDetailsSubject = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var userHeading: Observable<String?> { userHeadingSubject.asObservable() }
    var userValue: Observable<String?> { userValueSubject.asObservable() }
    var amountHeading: Observable<String?> { amountHeadingSubject.asObservable() }
    var amountValue: Observable<String?> { amountValueSubject.asObservable() }
    var feeValue: Observable<String?> { feeValueSubject.asObservable() }
    var vatValue: Observable<String?> { vatValueSubject.asObservable() }
    var totalAmountValue: Observable<String?> { totalAmountValueSubject.asObservable() }
    var cancelReason: Observable<String?> { cancelReasonSubject.asObservable() }
    var referenceNumber: Observable<String?> { referenceNumberSubject.asObservable() }
    var cardValue: Observable<String?> { cardValueSubject.asObservable() }
    var foreignAmountHeading: Observable<String?> { foreignAmountHeadingSubject.asObservable() }
    var foreignAmountValue: Observable<String?> { foreignAmountValueSubject.asObservable() }
    var exchangeRateValue: Observable<String?> { exchangeRateValueSubject.asObservable() }
    var remarks: Observable<String?> { remarksSubject.asObservable() }
    var isHidePaymentDetails: Observable<Bool>{ isHidePaymentDetailsSubject.asObservable() }
    
    private let transaction: TransactionResponse //CDTransaction
    
    init(transaction: TransactionResponse, isHidePaymentDetails: Bool = false) {
        self.transaction = transaction
        
        isHidePaymentDetailsSubject.onNext(isHidePaymentDetails)
        
        remarksSubject = BehaviorSubject(value: transaction.remarks)
        cardValueSubject = BehaviorSubject(value: transaction.maskedCardNumber)
        
        foreignAmountHeadingSubject = BehaviorSubject(value: nil)
        foreignAmountValueSubject = BehaviorSubject(value: nil)
        exchangeRateValueSubject = BehaviorSubject(value: nil)
        
        // Commenting following code as business asked to hide exchange rate in international transactions of ecom/pos/atm for now.
        // showing 'cardHolderBillingAmount' in amount section in every case. and amount spent in foreign CURRENCY is in section 'spent in AED'.
        if (transaction.productCode == .swift || transaction.productCode == .rmt ), //|| transaction.isNonAEDTransaction),
            let fxRate = transaction.fxRate ,  let foriegnCurrency = transaction.currency {
            foreignAmountValueSubject.onNext(CurrencyFormatter.format(amount: transaction.amount, in: foriegnCurrency))
          /*  foreignAmountHeadingSubject.onNext(transaction.isNonAEDTransaction ? "Spent amount" : "Transfer amount") */
            foreignAmountHeadingSubject.onNext(transaction.currency != "PKR" ? "Spent amount" : "Transfer amount")
          /*  exchangeRateValueSubject.onNext(transaction.isNonAEDTransaction ? nil : "\(CurrencyFormatter.format(amount: 1, in: foriegnCurrency)) = PKR \(fxRate.replacingDecimalSeparator())")*/
            exchangeRateValueSubject.onNext(transaction.currency != "PKR" ? nil : "\(CurrencyFormatter.format(amount: 1, in: foriegnCurrency)) = PKR \(fxRate.replacingDecimalSeparator())")
            
        }  /*else {
            amountValueSubject = BehaviorSubject<String?>(value: CurrencyFormatter.formatAmountInLocalCurrency(transaction.amount))
        }
        
        if transaction.transactionProductCode.isFee && transaction.transactionProductCode != .manualAdjustment {
            amountValueSubject.onNext(CurrencyFormatter.formatAmountInLocalCurrency(0))
        } */
        
        amountValueSubject = BehaviorSubject<String?>(value: CurrencyFormatter.formatAmountInLocalCurrency(transaction.cardHolderBillingTotalAmount))
        
        
        feeValueSubject.onNext(transaction.productCode.hideFeeAndVat ? nil : CurrencyFormatter.formatAmountInLocalCurrency(transaction.fee))
        vatValueSubject = BehaviorSubject<String?>(value: transaction.productCode.hideFeeAndVat ? nil : CurrencyFormatter.formatAmountInLocalCurrency(transaction.vat) )
        
        if transaction.productCode.isFee && transaction.productCode != .manualAdjustment {
            totalAmountValueSubject = BehaviorSubject<String?>(value: CurrencyFormatter.formatAmountInLocalCurrency(transaction.totalAmount ?? 0))
        } else {
            totalAmountValueSubject = BehaviorSubject<String?>(value: nil)
        }
        
        
        referenceNumberSubject = BehaviorSubject<String?>(value: transaction.transactionId)
        
        let productCode = transaction.productCode
        var title = transaction.type.title(forProductCode: productCode)
        if productCode == .balanceInquiry || productCode == .miniStatement || productCode == .accountStatusInquiry {
            title = nil
        }
        amountHeadingSubject = BehaviorSubject<String?>(value: transaction.isInternationaleComAndPos ? "Spent in PKR" : title)
        
        userHeadingSubject = BehaviorSubject<String?>(value: transaction.type.userInfoTitle)
        userValueSubject = BehaviorSubject<String?>(value: nil)
        
        cancelReasonSubject = BehaviorSubject<String?>(value: nil)
        
        cancelReasonSubject.onNext(transactionCancelReason)
        userValueSubject.onNext(userInfo())
        cardValueSubject.onNext(maskedCardNumber)
    }
}

private extension TransactionDetailsAmountInfoCellViewModel {
    func userInfo() -> String? {
        let productCode = transaction.productCode
        
        guard productCode == .y2yTransfer || productCode == .domestic || productCode == .uaeftsTransfer || productCode == .cashPayout || productCode == .swift || productCode == .rmt else { return nil }
        
        let type = transaction.type
        
        if type == .credit { return transaction.senderName }
        
        return nil
    }
    
    var maskedCardNumber: String? {
        guard let cardNumber = transaction.maskedCardNumber else { return nil }
        
        return "*\(cardNumber.suffix(4))"
    }
    
    var transactionCancelReason: String? {
        
        switch transaction.transactionStatus {
//
//        case .cancelled:
//            return transaction.cancelReason == nil ? nil : "\(transaction.cancelReason!)\n"
            
        case .pending:
            switch transaction.productCode {
            case .swift, .rmt:
                // TODO: Localize this text once finalazed source of this transaction
                return "Transfers made after 2:00 PM PKR time will be processed on the next business day.  There maybe an impact on the FX rate at the time of transfer.\n"
                
            default:
                return nil
                
            }
            
        case .failed, .cancelled:
            return "Sorry! We're unable to complete your transfer at this point. Don't worry, we've gone ahead and cancelled it for you."
            
        default:
            return nil
            
        }
        
    }
}

fileprivate extension TransactionType {
    
    func title(forProductCode productCode: TransactionProductCode) -> String? { return "Amount" }
    
    var userInfoTitle: String? {
        switch self {
        case .credit:
            return "screen_transaction_details_display_text_sendare_name".localized
        case .unknown, .debit:
            return nil
        }
    }
}
