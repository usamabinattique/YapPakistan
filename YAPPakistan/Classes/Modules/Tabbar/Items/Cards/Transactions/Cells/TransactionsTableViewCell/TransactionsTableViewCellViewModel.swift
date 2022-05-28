//
//  TransactionsTableViewCellViewModel.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 27/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import RxSwift
import YAPComponents
import RxTheme
/// import AppDatabase

protocol TransactionsTableViewCellViewModelInputs {
    
}

protocol TransactionsTableViewCellViewModelOutputs {
    var shimmering: Observable<Bool> { get }
    var transactionTitle: Observable<String?> { get }
    var transactionTimeCategory: Observable<String?> { get }
    var currency: Observable<String?> { get }
    var transactionAmount: Observable<NSAttributedString?> { get }
    var transactionImageUrl: Observable<ImageWithURL> { get }
    var transactionType: Observable<TransactionType?> { get }
    var transactionProductCode: Observable<TransactionProductCode> { get }
    var imageContentMode: Observable<UIView.ContentMode> { get }
    var remarks: Observable<String?> { get }
    var transactionStatus: Observable<String?> { get }
    var transactionTypeIcon: Observable<UIImage?> { get }
    var transactionTypeBackground: Observable<UIColor> { get }
    var transactionTypeTint: Observable<UIColor> { get }
    var cancelled: Observable<Bool> { get }
    var transactionAmountTextColor: Observable<UIColor?>{ get }
    var transactionStatusColor: Observable<UIColor?>{ get }
    var addVirtualCardDesignGradient: Observable<[UIColor]?> { get }
    var internationalAmount: Observable<String?> { get }
}

protocol TransactionsTableViewCellViewModelType {
    var inputs: TransactionsTableViewCellViewModelInputs { get }
    var outputs: TransactionsTableViewCellViewModelOutputs { get }
}

class TransactionsTableViewCellViewModel: TransactionsTableViewCellViewModelType,
                                          TransactionsTableViewCellViewModelInputs,
                                          TransactionsTableViewCellViewModelOutputs,
                                          ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TransactionsTableViewCellViewModelInputs { return self}
    var outputs: TransactionsTableViewCellViewModelOutputs { return self }
    var reusableIdentifier: String { return TransactionsTableViewCell.defaultIdentifier }
    var transaction: TransactionResponse!
    let transactionId: String
    let cdTransaction: CDTransaction?
    
    private let transactionTitleSubject: BehaviorSubject<String?>
    private let transactionTimeCategorySubject: BehaviorSubject<String?>
    private var currencySubject: BehaviorSubject<String?>
    private let transactionAmountSubject: BehaviorSubject<NSAttributedString?>
    private let transactionImageUrlSubject: BehaviorSubject<ImageWithURL>
    private let transactionTypeSubject: BehaviorSubject<TransactionType?>
    private let transactionProductCodeSubject: BehaviorSubject<TransactionProductCode>
    private let senderNameSubject: BehaviorSubject<String?>
    private let receiverNameSubject: BehaviorSubject<String?>
    private let contentModeSubject = BehaviorSubject<UIView.ContentMode>(value: .center)
    private let remarksSubject = BehaviorSubject<String?>(value: nil)
    private let transactionStatusSubject = BehaviorSubject<String?>(value: nil)
    private let transactionTypeIconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let transactionTypeBackgroundSubject = BehaviorSubject<UIColor>(value: .green) //.secondaryGreen)
    private let transactionTypeTintSubject = BehaviorSubject<UIColor>(value: .white)
    private let cancelledSubject = BehaviorSubject<Bool>(value: false)
    private let transactionAmountTextColorSubject = ReplaySubject<UIColor?>.create(bufferSize: 1)
    private let transactionStatusColorSubject = BehaviorSubject<UIColor?>(value: nil)
    private let shimmeringSubject = BehaviorSubject<Bool>(value: false)
    private let addVirtualCardDesignGradientSubject = BehaviorSubject<[UIColor]?>(value: nil)
    private let internationalAmountSubject = BehaviorSubject<String?>(value: nil)
    
    // MARK:- Inputs
    
    // MARK: - Outputs
    var transactionTitle: Observable<String?> { transactionTitleSubject.asObservable() }
    var transactionTimeCategory: Observable<String?> { return transactionTimeCategorySubject.asObservable() }
    var transactionAmount: Observable<NSAttributedString?> { return transactionAmountSubject.asObservable() }
    var currency: Observable<String?> { return currencySubject.asObservable() }
    var transactionImageUrl: Observable<ImageWithURL> { return transactionImageUrlSubject.asObservable() }
    var transactionType: Observable<TransactionType?> { return transactionTypeSubject.asObservable() }
    var transactionProductCode: Observable<TransactionProductCode> { return transactionProductCodeSubject.asObservable() }
    var imageContentMode: Observable<UIView.ContentMode> { contentModeSubject.asObservable() }
    var remarks: Observable<String?> { remarksSubject.asObservable() }
    var transactionStatus: Observable<String?> { transactionStatusSubject.asObservable() }
    var transactionTypeBackground: Observable<UIColor> { transactionTypeBackgroundSubject.asObservable() }
    var transactionTypeIcon: Observable<UIImage?> { transactionTypeIconSubject.asObservable() }
    var transactionTypeTint: Observable<UIColor> { transactionTypeTintSubject.asObservable() }
    var cancelled: Observable<Bool> { cancelledSubject.asObservable() }
    var transactionAmountTextColor: Observable<UIColor?>{ return transactionAmountTextColorSubject.asObservable() }
    var transactionStatusColor: Observable<UIColor?>{ return transactionStatusColorSubject.asObservable() }
    // var transactionIconBackground: Observable<UIColor> { transactionIconBackgroundSubject.asObservable() }
    var shimmering: Observable<Bool> { return shimmeringSubject.asObservable() }
    var addVirtualCardDesignGradient: Observable<[UIColor]?> { addVirtualCardDesignGradientSubject }
    var internationalAmount: Observable<String?> { internationalAmountSubject }
    
    init(transaction: TransactionResponse, themeService: ThemeService<AppTheme>) {
        self.transaction = transaction
        self.transactionId = "\(transaction.id)"
        let title = transaction.title ?? "Unknown"
       
        transactionTitleSubject = BehaviorSubject(value: transaction.finalizedTitle)
        transactionTimeCategorySubject = BehaviorSubject(value: transaction.formattedTime + " · " + ((transaction.productNameType != .unkonwn ? transaction.productNameType.type : transaction.merchantCategory ?? transaction.category)))//transaction.category)
        
        let amount = CurrencyFormatter.format(amount: transaction.amount, in: CurrencyType(rawValue: transaction.currency ?? "") ?? .pkr).amountFromFormattedAmount
        transactionAmountSubject = BehaviorSubject(value: NSAttributedString(string: (transaction.type == .debit ? "-" : "+") + amount))
        currencySubject = BehaviorSubject(value: transaction.currency)
        
        transactionTypeSubject = BehaviorSubject(value: transaction.type)
        transactionProductCodeSubject = BehaviorSubject(value: transaction.productCode)
        senderNameSubject = BehaviorSubject(value: transaction.senderName)
        receiverNameSubject = BehaviorSubject(value: transaction.receiverName)
        
        let icon = transaction.icon.identifierImage /*transaction.productCode.icon(
            forTransactionType: transaction.type,
            transactionStatus: TransactionStatus(rawValue: transaction.status ?? "") ?? .none)
            ?? transaction.type.icon
            ?? title.initialsImage(color: transaction.color,
                                   font: .small,
                                   size: CGSize(width: 40, height: 40) ) */
        let url = transaction.type == .debit ? transaction.receiverUrl : transaction.senderUrl
        transactionTypeIconSubject.onNext(icon)
        transactionImageUrlSubject = BehaviorSubject(value: (url, transaction.title?.thumbnail))
        contentModeSubject.onNext(transaction.icon.contentMode)
        transactionTypeBackgroundSubject.onNext(transaction.transactionTypeBackgroundColor())
        
        transactionTypeTintSubject.onNext(transaction.transactionTypeTintColor() ?? UIColor.red)
        
        cdTransaction = nil
        
        Observable.combineLatest(transactionType, cancelled)
            .subscribe(onNext: { [weak self] type, cancelled in
                self?.transactionAmountTextColorSubject.onNext(type == .debit ? UIColor(themeService.attrs.primaryDark)  : UIColor(themeService.attrs.secondaryGreen))
                self?.transactionStatusColorSubject.onNext(cancelled ? UIColor(themeService.attrs.grey) : UIColor(themeService.attrs.greyDark))
            }).disposed(by: disposeBag)
        
        if let remarks = transaction.remarks {
            remarksSubject.onNext(remarks)
        }
        
        shimmeringSubject.onNext(false)
    }
    
//    init(transaction: CDTransaction) {
//        self.cdTransaction = transaction
//        let title = transaction.finalizedTitle ?? "Unknown"
//        self.transactionId = transaction.transactionId ?? ""
        
 //       transactionTitleSubject = BehaviorSubject(value: "")
//                                                    transaction.category?.lowercased() == "decline_fee" && transaction.transactionProductCode == .atmWithdrawl ? "screen_transaction_details_display_text_category_declined_name".localized : title)
//
//        var transactionCategory: String {
//            let isTapixCategoryEmpty = transaction.tapixCategory?.lowercased() == "general" || transaction.tapixCategory == nil
//            return transaction.transactionProductCode.shouldDisplayCategory ? (isTapixCategoryEmpty ? transaction.transferType ?? "" : transaction.tapixCategory ?? "") : transaction.transferType ?? ""
//        }
//        self.transactionTimeCategorySubject = BehaviorSubject(value: transaction.time + " · " + transactionCategory)
//
//        let amount: String
//
//        let internationalAmount = CurrencyFormatter.format(amount: transaction.amount, in: transaction.currency ?? "AED")
//        internationalAmountSubject.onNext((transaction.isNonAEDTransaction || transaction.transactionProductCode == .rmt || transaction.transactionProductCode == .swift) ? internationalAmount : "")
//        currencySubject = BehaviorSubject(value: transaction.cardHolderBillingCurrency ?? "AED")
//        amount = CurrencyFormatter.format(amount: transaction.cardHolderBillingTotalAmount, in: transaction.cardHolderBillingCurrency ?? "AED").amountFromFormattedAmount
        
        /*
         if transaction.transactionProductCode == .rmt || transaction.transactionProductCode == .swift || transaction.isNonAEDTransaction {
         currencySubject = BehaviorSubject(value: transaction.otherBankCurrency ?? transaction.currency ?? "AED")
         amount = CurrencyFormatter.format(amount: transaction.amount, in: transaction.currency ?? "AED").amountFromFormattedAmount
         } else {
         let currency = transaction.currency ?? "AED"
         currencySubject = BehaviorSubject(value: currency)
         amount = CurrencyFormatter.format(amount: transaction.calculatedTotalAmount, in: currency).amountFromFormattedAmount
         }
         */
        
//        transactionTypeSubject = BehaviorSubject(value: transaction.transactionType)
//        transactionProductCodeSubject = BehaviorSubject(value: (transaction.productCode.map { TransactionProductCode(rawValue: $0) ?? .unknown } ?? .unknown))
//        senderNameSubject = BehaviorSubject(value: transaction.senderName)
//        receiverNameSubject = BehaviorSubject(value: transaction.receiverName)
//        let icon = transaction.icon
//        transactionImageUrlSubject = BehaviorSubject(value: (icon.imageUrl, icon.image))
//        contentModeSubject.onNext(icon.contentMode)
//        if transaction.transactionProductCode == .y2yTransfer {
//            remarksSubject.onNext(transaction.remarks)
//        }
//
//        transactionTypeIconSubject.onNext(transaction.identifierImage)
//
//        transactionTypeBackgroundSubject.onNext(transaction.transactionTypeBackgroundColor())
//
//        transactionTypeTintSubject.onNext(transaction.transactionTypeTintColor() ?? .red ) //UIColor.error
//
//        cancelledSubject.onNext(transaction.transactionStatus == .cancelled || transaction.transactionStatus == .failed)
//
//        let amountText = transaction.transactionDebitCreditHandlar + amount
//
//        let attributed = NSMutableAttributedString(string: amountText)
//
//        if transaction.transactionStatus == .cancelled || transaction.transactionStatus == .failed {
//            attributed.addAttributes([.strikethroughStyle : 1], range: NSRange(location: 0, length: attributed.length))
//        }
        
//        transactionAmountSubject = BehaviorSubject(value: attributed)
        
//         This chunk of code will be remove once qa verified the PP build 65.
//        Observable.combineLatest(transactionType, cancelled)
//            .subscribe(onNext: { [weak self] type, cancelled in
//                self?.transactionAmountTextColorSubject.onNext(cancelled ? .primaryDark :
//        type == .debit ? .primaryDark : transaction.transactionProductCode.addRemoveFunds
//            || transaction.transactionStatus == .pending
//            || transaction.transactionStatus == .inProgress ? .primaryDark : UIColor.appColor(ofType: .secondaryGreen))
//                self?.transactionStatusColorSubject.onNext(cancelled ? .grey : .greyDark)
//            }).disposed(by: disposeBag)
        
//        Observable.combineLatest(transactionType, cancelled)
//            .subscribe(onNext: { [weak self] type, cancelled in
//                self?.transactionAmountTextColorSubject.onNext(type == .debit ? .blue: .green) // .primaryDark : .secondaryGreen
//                self?.transactionStatusColorSubject.onNext(cancelled ? .gray: .darkGray) //.grey : .greyDark)
//            }).disposed(by: disposeBag)
//
//
//        transactionStatusSubject.onNext(transaction.finalizedStatus)
//        bindVirtualCardBackground(transaction: transaction)
//        shimmeringSubject.onNext(false)
//    }
    
    func bindVirtualCardBackground(transaction: CDTransaction) {
//        guard transaction.transactionProductCode == .addFundsSupplementaryCard ||
//                transaction.transactionProductCode == .removeFundsSuplementaryCard else { return }
//        var gradientColors = transaction.virtualCardColors
//            .map { $0.split(separator: ",").map { String($0) } }
//            .map { $0.map { UIColor(Color(hex: $0)) } }
//        gradientColors = (gradientColors == nil || gradientColors?.count == 0) ? [#colorLiteral(red: 0.9103790522, green: 0.887635529, blue: 0.9884166121, alpha: 1)] : gradientColors
//        addVirtualCardDesignGradientSubject.onNext(gradientColors)
    }
    
    init() {
        /// Adding dummy data for shimmer effect
        cdTransaction = nil
        transactionId = "Dummy Id"
        let title = "This is shimmergin dummy data"
        transactionTitleSubject = BehaviorSubject(value: title)
        transactionTimeCategorySubject = BehaviorSubject(value: "This is dummy data")
        
        let amount = "AED 1000"
        
        transactionImageUrlSubject = BehaviorSubject(value: ("icon.imageUrl", nil))
        //        remarksSubject.onNext(nil)
        currencySubject = BehaviorSubject(value: nil)
        
        let amountText =  amount
        let attributed = NSMutableAttributedString(string: amountText)
        
        attributed.addAttributes([.strikethroughStyle : 1], range: NSRange(location: 0, length: attributed.length))
        
        transactionAmountSubject = BehaviorSubject(value: attributed)
        
        // transactionIconBackgroundSubject.onNext(.white)
        
        transactionTypeSubject = BehaviorSubject(value: nil)
        transactionProductCodeSubject = BehaviorSubject(value: TransactionProductCode.addFundsSupplementaryCard)
        senderNameSubject = BehaviorSubject(value: nil)
        receiverNameSubject = BehaviorSubject(value: nil)
        
        shimmeringSubject.onNext(true)
    }
}
