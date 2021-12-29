//
//  CDTransaction+CoreDataClass.swift
//  AppDatabase
//
//  Created by Zain on 18/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
//
// swiftlint:disable line_length
// swiftlint:disable identifier_name

//import Foundation
//import CoreData
//import YAPComponents
//
public enum TransactionCardType: String {
    case debit = "debit"
    case other = "other"
}
//
//@objc(CDTransaction)
//class CDTransaction: NSManagedObject {
//
////    @discardableResult
////    static func update(with model: TransactionResponse, transactionCardType: TransactionCardType, onContext context: NSManagedObjectContext, cardSerialNumber: String?) -> Bool {
////        //let entityHandler = CDTransactionEntityHandler()
////
////        guard model.updatedDate != nil else { return true }
////
////        //let transaction = entityHandler.transaction(withId: model.id, transactionCardType: transactionCardType, onContext: context) ?? entityHandler.create(onContext: context)
////
////        return transaction.update(with: model, transactionCardType: transactionCardType, onContext: context, cardSerialNumber: cardSerialNumber)
////    }
//
////    @discardableResult
////    internal func update(with model: TransactionResponse, transactionCardType: TransactionCardType, onContext context: NSManagedObjectContext, cardSerialNumber: String?) -> Bool {
////
////        let updated = model.updatedDate != updatedDate || model.status != status || model.category != category || model.fee != fee || model.vat != vat || model.transactionNote != transactionNote
////
////        createdDate = model.date
////        updatedDate = model.updatedDate
////        self.id = Int64(model.id)
////        productName = model.productName
////        category = model.category
////        type = model.type.rawValue
////        amount = model.amount
////        totalAmount = model.totalAmount ?? 0
////        currency = model.currency
////        status = model.status
////        paymentMode = model.paymentMode
////        initiator = model.merchant
////        transactionId = model.transactionId
////        /// this is done for the scenario that if user changes his card, his old transactions were not displaying, that's why to fetch all transactions we are temporariy changing his card serial number with latest serial number
////        self.cardSerialNumber = cardSerialNumber ?? model.card
////        transactionDay = model.date.startOfDay
////        title = model.title
////        closingBalance = model.closingBalance ?? 0
////        productCode = model._productCode
////        senderName = model.senderName
////        receiverName = model.receiverName
////        transactionNote = model.transactionNote
////        fee = isNonAEDTransaction ? model.markupFee ?? 0 : model.fee + (model.markupFee ?? 0)
////        vat = model.vat
////        merchantCategory = model.merchantCategory
////        merchantLogo = model.merchantLogoUrl
////        location = model.location
////        senderUrl = model.senderUrl
////        receiverUrl = model.receiverUrl
////        maskedCardNumber = model.maskedCardNumber
////        cancelReason = model.cancelReason
////        cardType = model.cardType
////        self.transactionCardType = transactionCardType.rawValue
////        otherBankName = model.otherBankName
////        otherBankCurrency = model.otherBankCurrency
////        otherBankCountry = model.otherBankCountry
////        otherBankBIC = model.otherBankBIC
////        fxRate = isNonAEDTransaction ? String.init(format: "\((model.cardHolderBillingAmount) < (model.amount) ? "%0.6f" : "%0.3f")", (model.cardHolderBillingAmount ?? amount)/amount) : model.fxRate
////        settlementAmount = isNonAEDTransaction ? model.cardHolderBillingAmount: model.settlementAmount
////        transactionNoteDate = model.transactionNoteDate ?? nil
////        itemIndex = Int64(model.index ?? 0)
////        customerId = model.customerId
////        remarks = model.remarks
////        formattedTime = model.formattedTime
////        calculatedAmount = model.calculatedTotalAmount
////        finalizedTitle = model.finalizedTitle
////        transferType = model.transferType
////        detailTransferType = model.detailTransferType
////        iconName = model.icon
////        statusIconName = model.statusIcon
////        finalizedStatus = model.finalizedStatus
////        receiverTransactionNote = model.receiverTransactionNote
////        receiverTransactionNoteDate = model.receiverTransactionNoteDate
////        merchantName = model.merchantName
////        virtualCardColors = model.virtualCardDesignCode.map { $0.colorCodes.map { $0.colorCode }.joined(separator: ",") }
////        isTransactionInProgress = model.isTransactionInProgress
////        beneficiaryId = model.beneficiaryId
////        senderCustomerId = model.senderCustomerId
////        tapixCategory = model.tapixCategory?.name
////        tapixCategoryIconURL = model.tapixCategory?.iconUrl
////        cardHolderBillingCurrency = model.cardHolderBillingCurrency
////        cardHolderBillingTotalAmount = model.cardHolderBillingTotalAmount
////        cardHolderBillingAmount = model.cardHolderBillingAmount
////        latitude = model.latitude
////        longitude = model.longitude
////
////        return updated
////    }
//
//    var calculatedTotalAmount: Double {
//        guard !(transactionProductCode == .rmt || transactionProductCode == .swift || isNonAEDTransaction || transactionProductCode == .masterCardRefund ) else {
//
//            if transactionProductCode == .eCom || transactionProductCode == .posPurchase || transactionProductCode == .masterCardRefund {
//                return cardHolderBillingTotalAmount
//            }
//            return settlementAmount + vat + fee
//        }
//        guard transactionType == .credit else { return totalAmount }
//        return amount
//    }
//
//    var isNonAEDTransaction: Bool {
//        (transactionProductCode == .posPurchase || transactionProductCode == .atmDeposit || transactionProductCode == .atmWithdrawl || transactionProductCode == .eCom) && currency != "AED"
//    }
//
//    var isInternationaleComAndPos: Bool {
//        (transactionProductCode == .posPurchase || transactionProductCode == .eCom) && currency != "AED"
//    }
//
//    var time: String {
//        let timeFormatter = DateFormatter()
//        timeFormatter.dateFormat = "hh:mm a"
//        timeFormatter.amSymbol = "AM"
//        timeFormatter.pmSymbol = "PM"
//        return timeFormatter.string(from: createdDate ?? Date())
//    }
//
//    var transactionType: TransactionType {
//        return TransactionType(rawValue: type ?? "") ?? .unknown
//    }
//
//    var transactionProductCode: TransactionProductCode {
//        return TransactionProductCode(rawValue: productCode ?? "") ?? .unknown
//    }
//
//    var transactionStatus: TransactionStatus { TransactionStatus.init(rawValue: status ?? "") ?? .none }
//
//    var transactionTitle: String? {
//        switch transactionProductCode {
//        case .domestic, .rmt, .swift, .uaeftsTransfer, .cashPayout, .y2yTransfer:
//            return transactionType == .debit ? (receiverName == nil ? nil :"To \(receiverName!)") : transactionType == .credit ? (senderName == nil ? nil :"From \(senderName!)") : nil ?? title
//        case .topUpByExternalCard:
//            guard let last4digit = maskedCardNumber?.suffix(4) else { return title }
//            return "Money added via *\(last4digit)"
//
//        case .addFundsSupplementaryCard:
//            return "Add to Virtual Card"
//        case.removeFundsSuplementaryCard:
//            return "Withraw from Virtual Card"
//        default:
//            return title
//        }
//    }
//
//    var transactionTypeTextColor: UIColor {
//        guard !(transactionStatus == .cancelled || transactionStatus == .pending || transactionStatus == .failed || isTransactionInProgress) else {
//            return UIColor.blue //.primaryDark
//        }
//        return .darkGray //.greyDark
//    }
//
//    var icon: (image: UIImage?, contentMode: UIView.ContentMode, imageUrl: String?) {
//        let title = self.title ?? "Unknown Transaction"
//        var icon: UIImage? = nil
//        var contentMode: UIView.ContentMode = .scaleAspectFill
//        var url: String? = nil
//
//        var name:String? = ""
//        if(transactionProductCode == .y2yTransfer) {
//            name = transactionType == .debit ? receiverName : senderName
//        }else if(transactionProductCode == .posPurchase || transactionProductCode == .eCom) {
//            name  = merchantName
//        }else{
//            name = title
//        }
//
//
//        url = transactionType == .debit ? receiverUrl : senderUrl
//        contentMode = .scaleAspectFill
//
//        if icon == nil {
//            icon = iconName.flatMap {
//                UIImage.sharedImage(named: $0)
//            }
//
//            if icon != nil {
//                if transactionProductCode.isFee || transactionProductCode.isIncoming || transactionProductCode == .y2yTransfer || transactionProductCode.isSendMoney {
//                    contentMode = .scaleAspectFill
//                } else if transactionProductCode == .addFundsSupplementaryCard || transactionProductCode == .removeFundsSuplementaryCard {
//                    contentMode = .center
//                }
//            }
//        }
//
//        if icon == nil {
//            icon = name?.initialsImage(color: UIColor.colorFor(listItemIndex: Int(itemIndex)), font: .regular)
//
//            if icon != nil {
//                contentMode = .scaleAspectFill
//            }
//        }
//
//        if transactionProductCode == .posPurchase || transactionProductCode == .eCom {
//            let category = self.tapixCategory ?? "General"
//            let isCategoryGeneral = category.lowercased() == "general"
//            url = merchantLogo ?? tapixCategoryIconURL
//            if isCategoryGeneral {
//                icon = UIImage(named: "general_category_icon", in: Bundle.main, compatibleWith: nil)
//            }
//        }
//
//        if transactionStatus == .cancelled {
//            contentMode = .scaleAspectFill
//        }
//
//        return (icon, contentMode, url)
//    }
//
//    func transactionTypeBackgroundColor() -> UIColor {
//        return isTransactionInProgress ? .white : transactionType == .debit && (transactionProductCode == .y2yTransfer || transactionProductCode.isSendMoney || transactionProductCode == .cashPayout) ? .blue: .white // .secondaryBlue : .white
//    }
//
//    func transactionTypeTintColor() -> UIColor? {
//        return transactionStatus == .completed ? (transactionProductCode == .y2yTransfer || transactionProductCode.isSendMoney || transactionProductCode == .cashPayout) ? UIColor.white : .blue : .orange // .secondaryBlue : UIColor.secondaryOrange
//    }
//
//    var identifierImage: UIImage? {
//        let icon = statusIconName.flatMap { UIImage.sharedImage(named: $0) }
//        if isTransactionInProgress {
//            return icon?.asTemplate
//        }
//        return icon
//    }
//
//    var transactionDebitCreditHandlar: String {
//        return transactionType == .debit ? "-" : "+"
//    }
//}

//public extension UIColor {
//    static func colorFor(listItemIndex: Int) -> UIColor {
//        switch listItemIndex % 6 {
//        case 0: return .blue //.primarySoft
//        case 1: return .orange //.secondaryOrange
//        case 2: return .magenta //.secondaryMagenta
//        case 3: return .systemBlue // .secondaryBlue
//        case 4: return .green //.secondaryGreen
//        default: return .blue //.primary
//        }
//    }
//
//    static func randomColor()-> UIColor {
//        colorFor(listItemIndex: Int.random(in: 0...5))
//    }
//}
