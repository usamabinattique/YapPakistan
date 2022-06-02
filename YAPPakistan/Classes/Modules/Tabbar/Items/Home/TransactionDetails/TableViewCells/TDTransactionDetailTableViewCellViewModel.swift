//
//  TDTransactionDetailTableViewCellViewModel.swift
//  YAP
//
//  Created by Wajahat Hassan on 14/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxTheme

protocol TDTransactionDetailTableViewCellViewModelInputs {
    
}

protocol TDTransactionDetailTableViewCellViewModelOutputs {
    var logo: Observable<(ImageWithURL, UIImageView.ContentMode)>{ get }
    var statusIcon: Observable<UIImage> { get }
    var amount: Observable<NSAttributedString?>{ get }
    var name: Observable<String?>{ get }
    var symbol: Observable<String?>{ get }
    var categoryIcon: Observable<UIImage?>{ get }
    var categoryName: Observable<String?>{ get }
    var location: Observable<String?>{ get }
    var cancelled: Observable<Bool> { get }
    var iconBackgroundColor: Observable<UIColor> { get }
    var transactionType: Observable<String?>{ get }
    var transactionTypeTextColor: Observable<UIColor>{ get }
    var addVirtualCardDesignGradient: Observable<[UIColor]?> { get }
    var shouldShowSeparator: Observable<Bool> { get }
    var transactionTime: Observable<String?>{ get }
    var isCategoryStackHidden: Observable<Bool> { get }
}

protocol TDTransactionDetailTableViewCellViewModelType {
    var inputs: TDTransactionDetailTableViewCellViewModelInputs { get }
    var outputs: TDTransactionDetailTableViewCellViewModelOutputs { get }
}

class TDTransactionDetailTableViewCellViewModel: TDTransactionDetailTableViewCellViewModelType, TDTransactionDetailTableViewCellViewModelInputs, TDTransactionDetailTableViewCellViewModelOutputs, ReusableTableViewCellViewModelType {
    
  //  let localeManage = LocaleManager.shared
    var transaction: TransactionResponse
    let disposeBag = DisposeBag()
    var reusableIdentifier: String { return TDTransactionDetailTableViewCell.defaultIdentifier }
    
    var inputs: TDTransactionDetailTableViewCellViewModelInputs { return self}
    var outputs: TDTransactionDetailTableViewCellViewModelOutputs { return self }
    
    
    private let logoSubject = BehaviorSubject<(ImageWithURL, UIImageView.ContentMode)>(value: ((nil, nil), UIView.ContentMode.scaleAspectFit))
    private let statusIconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let amountSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let nameSubject = BehaviorSubject<String?>(value: nil)
    private let symbolSubject = BehaviorSubject<String?>(value: nil)
    private let categoryIconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let categoryNameSubject = BehaviorSubject<String?>(value: nil)
    private let locationSubject = BehaviorSubject<String?>(value: nil)
    private let cancelledSubject = BehaviorSubject<Bool>(value: false)
    private let iconBackgroundColorSubject = ReplaySubject<UIColor>.create(bufferSize: 1) //BehaviorSubject<UIColor>(value: UIColor.primary.withAlphaComponent(0.15))
    private let transactionTypeSubject = BehaviorSubject<String?>(value: nil)
    private let transactionTypeTextColorSubject = ReplaySubject<UIColor>.create(bufferSize: 1) //BehaviorSubject<UIColor>(value: UIColor(themeService.attrs.greyDark))//.greyDark)
    private let addVirtualCardDesignGradientSubject = BehaviorSubject<[UIColor]?>(value: nil)
    private let shouldShowSeparatorSubject = BehaviorSubject<Bool>(value: false)
    private let tranactionTimeSubject = ReplaySubject<String?>.create(bufferSize: 1)
    private let isCategoryStackHiddenSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    
    
    var logo: Observable<(ImageWithURL, UIImageView.ContentMode)>{ return logoSubject.asObservable() }
    var statusIcon: Observable<UIImage> { statusIconSubject.unwrap() }
    var amount: Observable<NSAttributedString?> { return amountSubject.asObservable() }
    var name: Observable<String?>{ return nameSubject.asObservable() }
    var symbol: Observable<String?>{ return symbolSubject.asObservable() }
    var categoryIcon: Observable<UIImage?>{ return categoryIconSubject.asObservable() }
    var categoryName: Observable<String?>{ return categoryNameSubject.asObservable() }
    var location: Observable<String?>{ return locationSubject.asObservable() }
    var cancelled: Observable<Bool> { cancelledSubject.asObservable() }
    var iconBackgroundColor: Observable<UIColor> { iconBackgroundColorSubject.asObservable() }
    var transactionType: Observable<String?>{ return transactionTypeSubject.asObservable() }
    var transactionTypeTextColor: Observable<UIColor>{ return transactionTypeTextColorSubject.asObservable() }
    var addVirtualCardDesignGradient: Observable<[UIColor]?> { addVirtualCardDesignGradientSubject }
    var shouldShowSeparator: Observable<Bool> { shouldShowSeparatorSubject }
    var transactionTime: Observable<String?>{ tranactionTimeSubject.asObservable() }
    var isCategoryStackHidden: Observable<Bool> { isCategoryStackHiddenSubject.asObservable() }
    
    private var themeService: ThemeService<AppTheme>
    
    init(transaction: TransactionResponse, themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        let title = transaction.finalizedTitle ?? "Unknown"
        self.transaction = transaction
      //  nameSubject.onNext(title)
        tranactionTimeSubject.onNext(transaction.transactionDetailTime)
        nameSubject.onNext(transaction.productCode == .atmWithdrawl && transaction.category.lowercased() == "decline_fee" ? "screen_transaction_details_display_text_category_declined_name".localized : title)
        
        let merchantNameImage = transaction.merchantName?.initialsImage(color: UIColor.colorFor(listItemIndex: 5))
        if transaction.productCode == .posPurchase || transaction.productCode == .eCom /*|| transaction.productCode == .billPayments*/ {
            logoSubject.onNext(((transaction.merchantLogoUrl, merchantNameImage), transaction.icon.contentMode))
        } else {
            logoSubject.onNext(((transaction.icon.imageUrl, transaction.icon.image), transaction.icon.contentMode))
        }
       
      /*  if (transaction.productCode == .atmDeposit || transaction.productCode == .atmWithdrawl) {
            statusIconSubject.onNext(transaction.icon.identifierImage)
        } */
        
        if (transaction.productCode == .ibftTransaction || transaction.productCode == .y2yTransfer) {
            statusIconSubject.onNext(transaction.icon.identifierImage)
            isCategoryStackHiddenSubject.onNext(false)
            
            categoryIconSubject.onNext(categoryImage?.asTemplate)
            categoryNameSubject.onNext( category)
        } else {
            isCategoryStackHiddenSubject.onNext(true)
        }
        
        shouldShowSeparatorSubject.onNext(transaction.productCode.shouldDisplayCategory)
        transactionTypeTextColorSubject.onNext(transaction.transactionTypeTintColor() ?? transaction.color)//transaction.transactionTypeTextColor)
     /*   categoryIconSubject.onNext( transaction.productCode != .posPurchase ? categoryImage : nil)
        categoryNameSubject.onNext( transaction.productCode != .posPurchase ? category : nil) */
        //        cancelledSubject.onNext(transaction.transactionStatus == .cancelled || (transaction.transactionStatus == .pending && (transaction.transactionProductCode == .swift || transaction.transactionProductCode == .rmt)))
        
        bindCategories()
        
        if transaction.category.lowercased() == "decline_fee" {
            let declinedText = "screen_transaction_details_display_text_category_declined".localized
            let attributed = NSMutableAttributedString(string: declinedText)
            let range = NSRange(location: 0, length: attributed.length)
            attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(themeService.attrs.secondaryMagenta) /*UIColor.appColor(ofType: .secondaryMagenta)*/, range: range)
            attributed.addAttribute(NSAttributedString.Key.font, value: UIFont.large, range: range)
            amountSubject.onNext(attributed)
        }
        else {
            symbolSubject.onNext("PKR")
            let amountText = "\(transaction.type.rawValue == TransactionType.debit.rawValue ? "-" : "+") \(CurrencyFormatter.formatAmountInLocalCurrency(transaction.cardHolderBillingAmount/*cardHolderBillingTotalAmount*/).amountFromFormattedAmount)"
            let attributed = NSMutableAttributedString(string: amountText)
            let range = NSRange(location: 0, length: attributed.length)
            if transaction.transactionStatus == .cancelled || transaction.transactionStatus == .failed {
                attributed.addAttributes([.strikethroughStyle : 1], range: range)
                attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(themeService.attrs.primaryDark) /*UIColor.appColor(ofType: .primary)*/, range: range)
            }
            amountSubject.onNext(attributed)
        }

        
        
        switch transaction.transactionStatus {
        case .cancelled, .failed:
            cancelledSubject.onNext(true)
        default:
            if transaction.isTransactionInProgress {
                cancelledSubject.onNext(true)
            } else {
                cancelledSubject.onNext(false)
            }
        }
        
        iconBackgroundColorSubject.onNext(transaction.transactionStatus == .cancelled || transaction.productCode.isIncoming ? .white : UIColor(themeService.attrs.primary).withAlphaComponent(0.15))
        bindVirtualCardBackground(transaction: transaction)
    }
    
    func bindVirtualCardBackground(transaction: TransactionResponse) {
        guard transaction.productCode == .addFundsSupplementaryCard ||
                transaction.productCode == .removeFundsSuplementaryCard else { return }
        var gradientColors = transaction.prepaidCardName // transaction.virtualeCardColors
            .map { $0.split(separator: ",").map { String($0) } }
            .map { $0.map { UIColor.init(hexString: $0) } }
        
        gradientColors = (gradientColors == nil || gradientColors?.count == 0) ? [#colorLiteral(red: 0.9103790522, green: 0.887635529, blue: 0.9884166121, alpha: 1)] : gradientColors
        addVirtualCardDesignGradientSubject.onNext(transaction.virtualCardDesignCode?.gradiants)//gradientColors)
    }
    
        func bindCategories() {
            if showLocation {
                locationSubject.onNext(transaction.productCode ==  .fundLoad ? transaction.otherBankName : transaction.location?.components(separatedBy: .whitespacesAndNewlines).filter{ !$0.isEmpty }.joined(separator: " "))
            }
            if transaction.productCode == .y2yTransfer {
                transactionTypeSubject.onNext(transaction.detailTransferType)
            }
        }
}

private extension TDTransactionDetailTableViewCellViewModel {
    var categoryImage: UIImage? {

        guard !transaction.productCode.isFee else {
            return UIImage.init(named: "icon_fee_blue", in: .yapPakistan)?.asTemplate //UIImage.init(named: "icon_fee_blue", in: cardsBundle, compatibleWith: nil)?.asTemplate
        }
        
        switch transaction.productCode {
        
        case .y2yTransfer:
            return UIImage.init(named: "icon_send_money_blue", in: .yapPakistan)?.asTemplate //UIImage.init(named: "icon_send_money_blue", in: cardsBundle, compatibleWith: nil)?.asTemplate
            
        case .addFundsSupplementaryCard, .removeFundsSuplementaryCard:
            return nil
            
        case .uaeftsTransfer, .domestic, .swift, .rmt, .cashPayout:
            return UIImage.init(named: "icon_send_money_blue", in: .yapPakistan)?.asTemplate //UIImage.init(named: "icon_send_money_blue", in: cardsBundle, compatibleWith: nil)?.asTemplate
            
        case .debitCardReorder:
            return UIImage.init(named: "icon_fee_blue", in: .yapPakistan)?.asTemplate //UIImage.init(named: "icon_fee_blue", in: cardsBundle, compatibleWith: nil)?.asTemplate
            
        case .atmWithdrawl, .cashDepositInBank, .chequeDepositInBank, .masterCardATMWithdrawl, .topUpByExternalCard, .inwardRemittance, .localInwardRemittance, .fundLoad, .atmDeposit, .ibftTransaction:
            return UIImage.init(named: "icon_topup_blue", in: .yapPakistan) //UIImage.init(named: "icon_topup_blue", in: cardsBundle, compatibleWith: nil)?.asTemplate
        case .posPurchase:
            return (CategoryType(rawValue: self.transaction.merchantCategory ?? "") ?? .other).icon
            
        default:
            return nil
        }
    }
}

private extension TDTransactionDetailTableViewCellViewModel {
    var category: String? {
        
        if transaction.productCode.isFee { return "Fee" }
        
        switch transaction.productCode {
        
        case .y2yTransfer:
          /*  if transaction.type == .credit { return "Incoming Transfer" } else { return "Outgoing Transfer" } */
            return "YAP to YAP transfer"
            
        case .topUpByExternalCard, .inwardRemittance, .localInwardRemittance, .cashDepositInBank, .chequeDepositInBank:
            return "Incoming Transfer"
            
        case .addFundsSupplementaryCard, .removeFundsSuplementaryCard:
            return nil
            
        case .uaeftsTransfer, .domestic, .swift, .rmt, .cashPayout:
            return "Outgoing Transfer"
            
        case .debitCardReorder:
            return "Fee"
            
        case .fundLoad:
            return "Incoming funds"
            
        case .atmDeposit:
            return "Cash deposit"
            
        case .atmWithdrawl, .masterCardATMWithdrawl:
            return transaction.category == "REVERSAL" ? "Reversal" : "Cash withdraw"
            
        case .posPurchase:
            return self.transaction.merchantCategory?.capitalized
        case .ibftTransaction:
            return "Outgoing transfer"
        default:
            return nil
        }
    }
    
    var showLocation: Bool  {
        
        switch transaction.productCode {
        case .atmWithdrawl, .posPurchase ,.eCom, .atmDeposit:
                return true
            default:
                return false
        }
    }
}
