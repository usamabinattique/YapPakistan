//
//  Transaction.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 22/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
// swiftlint:disable line_length
// swiftlint:disable identifier_name


import Foundation
import UIKit

public enum TransactionType: String, Codable {
    case debit = "DEBIT"
    case credit = "CREDIT"
    case unknown = "NA"
}

public enum ProductNameType: String {
    case yapToYap = "Y2Y_TRANSFER"
    case topup = "TOP_UP_VIA_CARD"
    case ibft = "IBFT"
    case unkonwn
    
    var type: String {
        switch self {
        case .yapToYap:
            return "YAP to YAP"
        case .topup:
            return "Top Up"
        case .ibft:
            return "IBFT"
        case .unkonwn:
            return ""
        }
    }
}

//public enum TransactionStatus: String {
//    case pending = "PENDING"
//    case inProgress = "IN_PROGRESS"
//    case completed = "COMPLETED"
//    case failed = "FAILED"
//    case cancelled = "CANCELLED"
//    case none = "NONE"
//}


public enum TransactionState: String, Codable {
    case fssStart = "FSS_START"
    case fssNotificationPending = "FSS_NOTIFICATION_PENDING"
    case rakCutOffTimeHold = "RAK_CUT_OFF_TIME_HOLD"
    case fssTimeout = "FSS_TIMEOUT"
    case fssReversalPending = "FSS_REVERSAL_PENDING"
    case unknown = "NA"

    var isInProgress: Bool {
        [.fssStart, .fssNotificationPending, .rakCutOffTimeHold, .fssTimeout, .fssReversalPending].contains(self)
    }
}

public extension TransactionType {
    var icon: UIImage? {
        switch self {
        case .credit:
            return UIImage.init(named: "icon_transaction_credit", in: .yapPakistan)?.asTemplate
        case .debit:
            return UIImage.init(named: "icon_transaction_debit", in: .yapPakistan)?.asTemplate
        case .unknown:
            return nil
        }
    }

    var identifierIcon: UIImage? {
        switch self {
        case .debit:
            return UIImage.init(named: "icon_transaction_type_debit", in: .yapPakistan)?.asTemplate
        case .credit:
            return nil
        case .unknown:
            return nil
        }
    }

    func identifierIcon(for status: TransactionStatus, for transactionProductCode: TransactionProductCode) -> UIImage? {
        guard  status != .failed && status != .cancelled else { return nil }
        guard status == .completed else { return UIImage.init(named: "icon_transaction_type_inprogress", in: .yapPakistan)?.asTemplate }

        if transactionProductCode == .atmDeposit {
            return UIImage.init(named: "icon_identifire_atm_deposit", in: .yapPakistan)
        } else if transactionProductCode == .atmWithdrawl {
            return UIImage.init(named: "icon_identifire_atm_withdrawal", in: .yapPakistan)
        }

        return identifierIcon
    }
}

struct TransactionResponse: Codable, Transaction {
    
    
    
    let date: Date
    let updatedDate: Date?
    private let _type: String?
    let amount: Double
    let currency: String?
    let category: String
    let paymentMode: String?
    let closingBalance: Double?
    let openingBalance: Double?
    var title: String?
    let merchant: String?
    let transactionId: String
    var transactionNote: String?
    var transactionNoteDate: Date?
    let card: String?
    var id: Int
    let productName: String?
    let _productCode: String?
    let totalAmount: Double?
    let status: String?
    let senderName: String?
    let receiverName: String?
    let fee: Double
    let vat: Double
    let merchantName: String?
    let merchantCategory: String?
    let merchantLogoUrl: String?
    let location: String?
    let senderUrl: String?
    let receiverUrl: String?
    let maskedCardNumber: String?
    let cancelReason: String?
    let cardType: String?
    let otherBankName: String?
    let otherBankCurrency: String?
    let otherBankCountry: String?
    let otherBankBIC: String?
    let otherBankBranch: String?
    let fxRate: String?
    let settlementAmount: Double
    var index: Int?
    var customerId: String?
    var remarks: String?
    var receiverTransactionNote: String?
    let receiverTransactionNoteDate: Date?
    let cardName1: String?
    let cardName2: String?
    let markupFee: Double?
    let cardHolderBillingAmount: Double
    let virtualCardDesignCode: CardDesign?
    private var _txnState: String?
    let beneficiaryId: String?
    let senderCustomerId: String?
    var transactionState: TransactionState? { TransactionState(rawValue: _txnState ?? "") ?? .unknown }
    var cardHolderBillingCurrency: String?
    var cardHolderBillingTotalAmount: Double
    var latitude: Double
    var longitude: Double
    var tapixCategory: TapixTransactionCategory?
//    let senderProfilePictureUrl: String?
//    let receiverProfilePictureUrl: String?
    var customerId1: String?
    var customerId2: String?
    
    var sectionDate: Date {
        return date.startOfDay
    }

    var type: TransactionType { TransactionType(rawValue: _type ?? "") ?? .unknown }

    var productCode: TransactionProductCode { TransactionProductCode(rawValue: _productCode ?? "") ?? .unknown }

    var time: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)
    }
    
    var transactionDetailTime: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "MMM d, yyyy . h:mm a"
        
//        let dateFormatterPrint = DateFormatter()
//        dateFormatterPrint.dateFormat = "MMM d, yyyy . h:mm a"
//
//        if let date = transaction.date.date(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS") {
//            let stringDate = dateFormatterPrint.string(from: date)
//            dateSubject.onNext("\(stringDate)")
//        }
        
        return timeFormatter.string(from: date)
    }
    
    public var calculatedTotalAmount: Double {
//        guard !(productCode == .rmt || productCode == .swift || isNonAEDTransaction || productCode == .masterCardRefund ) else {
        guard !(productCode == .rmt || productCode == .swift || productCode == .masterCardRefund ) else {
        
            if productCode == .eCom || productCode == .posPurchase || productCode == .masterCardRefund {
                return cardHolderBillingTotalAmount
            }
            return settlementAmount + vat + fee
        }
        guard type == .credit else { return totalAmount ?? 0 }
        return amount
    }
    
    var productNameType: ProductNameType { ProductNameType(rawValue: productName ?? "") ?? .unkonwn}
    
//    public var transactionProductCode: TransactionProductCode {
//        return TransactionProductCode(rawValue: productCode ?? "") ?? .unknown
//    }
    
    public var isNonPKRTransaction: Bool {
        (productCode == .posPurchase || productCode == .atmDeposit || productCode == .atmWithdrawl || productCode == .eCom) && currency != "PKR"
    }
    
    public var isInternationaleComAndPos: Bool {
        (productCode == .posPurchase || productCode == .eCom) && currency != "PKR"
    }
    
    public var transactionUserUrl: String? {
        switch type {
        case .credit:
            return receiverUrl
        case .debit:
            return senderUrl
        default:
            return nil
        }
    }
    
    public var transactionUserName: String? {
        switch type {
        case .credit:
            return receiverName
        case .debit:
            return senderName
        default:
            return nil
        }
    }
    
    public var icon: (image: UIImage?, contentMode: UIView.ContentMode, imageUrl: String?, identifierImage: UIImage?, emptyThumbnail: UIImage?) {
        let title = self.title ?? "Unknown Transaction"
        var icon: UIImage? = nil
        var emptyThumbnail: UIImage? = nil
        var contentMode: UIView.ContentMode = .scaleAspectFill
        var url: String? = nil
        var identifierImage: UIImage?

        var name:String? = ""
        if(productCode == .y2yTransfer) {
            name = type == .debit ? receiverName : senderName
        }else if(productCode == .posPurchase || productCode == .eCom) {
            name  = merchantName
        }else{
            name = title
        }


        url = type == .debit ? receiverUrl : senderUrl
        contentMode = .scaleAspectFill
        
        if identifierImage == nil {
            if type == .debit && productNameType == .yapToYap {
                identifierImage = UIImage.init(named: "icon_send_money_completed_secondary", in: .yapPakistan)
            } else if type == .credit && productNameType == .yapToYap {
                identifierImage = UIImage.init(named: "icon_received_money_completed", in: .yapPakistan)
            } else if productNameType == .topup {
                identifierImage = UIImage.init(named: "icon_identifire_atm_deposit", in: .yapPakistan)
            } else {
                identifierImage = UIImage.init(named: "icon_identifire_atm_withdrawal", in: .yapPakistan)
            }
        }
        
        if icon == nil {
           /*
            icon = iconName.flatMap {
                UIImage.sharedImage(named: $0)
            } */

            if icon != nil {
                if productCode.isFee || productCode.isIncoming || productCode == .y2yTransfer || productCode.isSendMoney {
                    contentMode = .scaleAspectFill
                } else if productCode == .addFundsSupplementaryCard || productCode == .removeFundsSuplementaryCard {
                    contentMode = .center
                }
            }
        }

        if icon == nil {
            icon = name?.thumbnail//initialsImage(color: UIColor.colorFor(listItemIndex: Int(itemIndex)))

            if icon != nil {
                contentMode = .scaleAspectFill
            }
        }
        
       /* if productCode == .posPurchase || productCode == .eCom || productCode == .billPayments {
            let category = self.tapixCategory ?? "General"
            let isCategoryGeneral = category.lowercased() == "general"
            url = merchantLogo ?? tapixCategoryIconURL
            if isCategoryGeneral {
                icon = UIImage(named: "general_category_icon", in: Bundle.main, compatibleWith: nil)
            }
        } */
        if productCode == .eCom {
            icon = name?.thumbnail//initialsImage(color: UIColor.colorFor(listItemIndex: Int(itemIndex)))
            if icon != nil {
                contentMode = .scaleAspectFill
            }
        }
        

        if transactionStatus == .cancelled {
            contentMode = .scaleAspectFill
        }
        
        emptyThumbnail = "".thumbnail
        
        return (icon, contentMode, url, identifierImage,emptyThumbnail)
    }
    
    func flipImageLeftRight(_ image: UIImage) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: image.size.width, y: image.size.height)
        context.scaleBy(x: -image.scale, y: -image.scale)

        context.draw(image.cgImage!, in: CGRect(origin:CGPoint.zero, size: image.size))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return newImage
    }
    
    public var transactionStatus: TransactionStatus { TransactionStatus.init(rawValue: status ?? "") ?? .none }
    
    public func transactionTypeBackgroundColor() -> UIColor {
        return isTransactionInProgress ? .white : type == .debit && (productCode == .y2yTransfer || productCode.isSendMoney || productCode == .cashPayout) ?  UIColor(Color(hex: "#478DF4"))  : .white
    }

    public func transactionTypeTintColor() -> UIColor? {
        return transactionStatus == .completed ? (productCode == .y2yTransfer || productCode.isSendMoney || productCode == .cashPayout) ? UIColor.white : UIColor(Color(hex: "#478DF4"))  : UIColor(Color(hex: "#F57F17"))
    }

    enum CodingKeys: String, CodingKey {
        case date = "creationDate"
        case card = "card1"
        case updatedDate = "updatedDate"
        case _type = "txnType"
        case amount = "amount"
        case currency = "currency"
        case category = "category"
        case paymentMode = "paymentMode"
        case closingBalance = "balanceAfter"
        case openingBalance = "balanceBefore"
        case title = "title"
        case merchant = "initiator"
        case transactionId = "transactionId"
        case transactionNote = "transactionNote"
        case transactionNoteDate = "transactionNoteDate"
        case productName = "productName"
        case _productCode = "productCode"
        case totalAmount = "totalAmount"
        case id = "id"
        case status = "status"
        case vat = "vatAmount"
        case fee = "postedFees"
        case senderName, receiverName
        case merchantName
        case merchantCategory = "merchantCategory"//"merchantCategoryName"
        case merchantLogoUrl = "merchantLogo"
        case location = "cardAcceptorLocation"
        case senderUrl = "senderProfilePictureUrl"
        case receiverUrl = "receiverProfilePictureUrl"
        case maskedCardNumber = "maskedCardNo"
        case cancelReason = "cancelReason"
        case cardType = "cardType"
        case otherBankName = "otherBankName"
        case otherBankCurrency = "otherBankCurrency"
        case otherBankCountry = "otherBankCountry"
        case otherBankBIC = "otherBankBIC"
        case otherBankBranch = "otherBankBranchName"
        case fxRate = "fxRate"
        case settlementAmount = "settlementAmount"
        case customerId = "customerId2"
        case remarks = "remarks"
        case receiverTransactionNote = "receiverTransactionNote"
        case receiverTransactionNoteDate = "receiverTransactionNoteDate"
        case cardName1, cardName2
        case markupFee = "markupFees"
        case cardHolderBillingAmount = "cardHolderBillingAmount"
        case virtualCardDesignCode = "designCodesDTO"
        case beneficiaryId = "beneficiaryId" 
        case _txnState = "txnState"
        case senderCustomerId = "customerId1"
        case cardHolderBillingCurrency
        case cardHolderBillingTotalAmount
        case latitude = "latitude"
        case longitude = "longitude"
        case tapixCategory = "yapCategoryDTO"
    }
   

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _type = try container.decodeIfPresent(String?.self, forKey: ._type) ?? ""
        title = try? container.decodeIfPresent(String?.self, forKey: .title) ?? ""
        
        if let am = try? container.decodeIfPresent(Double.self, forKey: .amount) ?? 0 {
            amount = am
        } else if let am = try? container.decodeIfPresent(String.self, forKey: .amount) {
            amount = Double(am) ?? 0
        } else {
            amount = 0.0
        }
        
       // amount = try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0
        fee = try container.decodeIfPresent(Double.self, forKey: .fee) ?? 0
        vat = try container.decodeIfPresent(Double.self, forKey: .vat) ?? 0
        currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? ""
        closingBalance = try? container.decodeIfPresent(Double?.self, forKey: .closingBalance) ?? 0
        openingBalance = try? container.decodeIfPresent(Double?.self, forKey: .openingBalance) ?? 0
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        paymentMode = try container.decodeIfPresent(String.self, forKey: .paymentMode) ?? ""
        merchant = try container.decodeIfPresent(String?.self, forKey: .merchant) ?? ""
        transactionNote = try? container.decodeIfPresent(String?.self, forKey: .transactionNote) ?? ""
        let dateString = try container.decodeIfPresent(String.self, forKey: .date) ?? ""
        let updatedDateString = (try? container.decodeIfPresent(String?.self, forKey: .updatedDate)) ?? ""
        let creationDate = DateFormatter.transactionDateFormatter.date(from: dateString.formattedDateString)
        self.date = creationDate ?? Date()
        self.updatedDate = DateFormatter.transactionDateFormatter.date(from: updatedDateString?.formattedDateString ?? "") ?? creationDate
        let transactionNoteDateString = try? container.decodeIfPresent(String.self, forKey: .transactionNoteDate)
        transactionNoteDate = DateFormatter.transactionDateFormatter.date(from: transactionNoteDateString != nil ? (transactionNoteDateString?.formattedDateString ?? "") : "")
        transactionId = try container.decodeIfPresent(String.self, forKey: .transactionId) ?? ""
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        card = try? container.decodeIfPresent(String.self, forKey: .card)
        productName = try? container.decodeIfPresent(String?.self, forKey: .productName) ?? ""
        _productCode = try container.decodeIfPresent(String?.self, forKey: ._productCode) ?? ""
        totalAmount = try? container.decodeIfPresent(Double.self, forKey: .totalAmount)
        status = try? container.decodeIfPresent(String.self, forKey: .status)
        senderName = try? container.decodeIfPresent(String?.self, forKey: .senderName) ?? ""
        receiverName = try? container.decodeIfPresent(String.self, forKey: .receiverName)
        merchantName = try? container.decodeIfPresent(String.self, forKey: .merchantName)
        merchantCategory = try? container.decodeIfPresent(String.self, forKey: .merchantCategory)
        merchantLogoUrl = try? container.decodeIfPresent(String.self, forKey: .merchantLogoUrl)
        location = try? container.decodeIfPresent(String.self, forKey: .location)
        senderUrl = try? container.decodeIfPresent(String.self, forKey: .senderUrl)
        receiverUrl = try? container.decodeIfPresent(String.self, forKey: .receiverUrl)
        maskedCardNumber = try? container.decodeIfPresent(String.self, forKey: .maskedCardNumber)
        cancelReason = try? container.decodeIfPresent(String.self, forKey: .cancelReason)
        cardType = try? container.decodeIfPresent(String.self, forKey: .cardType)
        otherBankName = try? container.decodeIfPresent(String.self, forKey: .otherBankName)
        otherBankCurrency = try? container.decodeIfPresent(String.self, forKey: .otherBankCurrency)
        otherBankCountry = try? container.decodeIfPresent(String.self, forKey: .otherBankCountry)
        otherBankBranch = try? container.decodeIfPresent(String.self, forKey: .otherBankBranch)
        otherBankBIC = try? container.decodeIfPresent(String.self, forKey: .otherBankBIC)
        fxRate = try? container.decodeIfPresent(String.self, forKey: .fxRate)
        settlementAmount = try container.decodeIfPresent(Double.self, forKey: .settlementAmount) ?? 0
        customerId = try? container.decodeIfPresent(String.self, forKey: .customerId)
        remarks = try? container.decodeIfPresent(String.self, forKey: .remarks)
        receiverTransactionNote = try? container.decodeIfPresent(String.self, forKey: .receiverTransactionNote)
        let receiverTransactionNoteDateString = try? container.decodeIfPresent(String.self, forKey: .transactionNoteDate)
        receiverTransactionNoteDate = DateFormatter.transactionDateFormatter.date(from: receiverTransactionNoteDateString != nil ? receiverTransactionNoteDateString!.formattedDateString : "")
        cardName1 = try? container.decodeIfPresent(String.self, forKey: .cardName1)
        cardName2 = try? container.decodeIfPresent(String.self, forKey: .cardName2)
        markupFee = try? container.decodeIfPresent(Double?.self, forKey: .markupFee) ?? 0
        cardHolderBillingAmount = try container.decodeIfPresent(Double.self, forKey: .cardHolderBillingAmount) ?? 0
        virtualCardDesignCode = try? container.decodeIfPresent(CardDesign.self, forKey: .virtualCardDesignCode)
        beneficiaryId = try? container.decodeIfPresent(String.self, forKey: .beneficiaryId)
        senderCustomerId = try? container.decodeIfPresent(String.self, forKey: .senderCustomerId)
        _txnState = try container.decodeIfPresent(String.self, forKey: ._txnState)
        cardHolderBillingCurrency = try? container.decodeIfPresent(String.self, forKey: .cardHolderBillingCurrency)
        cardHolderBillingTotalAmount = try container.decodeIfPresent(Double.self, forKey: .cardHolderBillingTotalAmount) ?? 0
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 0.0
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 0.0
        tapixCategory = try container.decodeIfPresent(TapixTransactionCategory.self, forKey: .tapixCategory)
    }

    init(withTransactionId id: String) {
        transactionId = id
        _type = TransactionType.credit.rawValue
        amount = 0
        title = ""
        currency = ""
        closingBalance = 0
        category = ""
        paymentMode = ""
        merchant = ""
        transactionNote = ""
        transactionNoteDate = nil
        self.id = 0
        date = Date()
        updatedDate = Date()
        card = ""
        productName = nil
        totalAmount = nil
        status = nil
        openingBalance = nil
        _productCode = TransactionProductCode.topUpByExternalCard.rawValue
        senderName = nil
        receiverName = nil
        fee = 0
        vat = 0
        merchantLogoUrl = nil
        merchantName = nil
        merchantCategory = nil
        location = nil
        senderUrl = nil
        receiverUrl = nil
        maskedCardNumber = nil
        cancelReason = nil
        cardType = nil
        otherBankName = nil
        otherBankBIC = nil
        otherBankBranch = nil
        otherBankCountry = nil
        otherBankCurrency = nil
        fxRate = nil
        settlementAmount = 0
        receiverTransactionNote = nil
        receiverTransactionNoteDate = nil
        cardName1 = ""
        cardName2 = ""
        markupFee = nil
        cardHolderBillingAmount = 0
        virtualCardDesignCode = nil
        beneficiaryId = nil
        senderCustomerId = nil
        _txnState = nil
        cardHolderBillingCurrency = nil
        cardHolderBillingTotalAmount = 0
        tapixCategory = nil
        latitude = 0.0
        longitude = 0.0
    }

    static let loadingId = "LOADINGTRANSACTIONS"

    static var loadingValue: TransactionResponse {
        return TransactionResponse.init(withTransactionId: loadingId)
    }

    var color: UIColor { .green } /// UIColor.colorFor(listItemIndex: index ?? 0)
}

extension TransactionResponse {
    static let iso8601Full: DateFormatter = { let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter }()
}

extension TransactionResponse {
    
    
}

extension TransactionResponse: Equatable {
    static func == (lhs: TransactionResponse, rhs: TransactionResponse) -> Bool {
        return lhs.date == rhs.date && lhs.amount == rhs.amount && lhs.cancelReason == rhs.cancelReason && lhs.card == rhs.card && lhs.cardType == rhs.cardType && lhs.category == rhs.category && lhs.closingBalance == rhs.closingBalance && lhs.currency == rhs.currency && lhs.fee == rhs.fee && lhs.fxRate == rhs.fxRate && lhs.id == rhs.id && lhs.location == rhs.location && lhs.maskedCardNumber == rhs.maskedCardNumber && lhs.merchant == rhs.merchant && lhs.merchantCategory == rhs.merchantCategory && lhs.merchantLogoUrl == rhs.merchantLogoUrl && lhs.openingBalance == rhs.openingBalance && lhs.otherBankBIC == rhs.otherBankBIC && lhs.otherBankBranch == rhs.otherBankBranch && lhs.otherBankCountry == rhs.otherBankCountry && lhs.otherBankName == rhs.otherBankName && lhs.paymentMode == rhs.paymentMode && lhs._productCode == rhs._productCode && lhs.productName == rhs.productName && lhs.receiverName == rhs.receiverName && lhs.receiverUrl == rhs.receiverUrl && lhs.sectionDate == rhs.sectionDate && lhs.senderName == rhs.senderName && lhs.senderUrl == rhs.senderUrl && lhs.settlementAmount == rhs.settlementAmount && lhs.status == rhs.status && lhs.time == rhs.time && lhs.title == rhs.title && lhs.totalAmount == rhs.totalAmount && lhs.transactionId == rhs.transactionId && lhs.transactionNote == rhs.transactionNote && lhs._type == rhs._type && lhs.updatedDate == rhs.updatedDate && lhs.vat == rhs.vat && lhs.index == rhs.index && lhs.receiverTransactionNote == rhs.receiverTransactionNote && lhs.cardHolderBillingCurrency == rhs.cardHolderBillingCurrency && lhs.cardHolderBillingTotalAmount == rhs.cardHolderBillingTotalAmount
    }
}

// Mock Transaction Init
extension TransactionResponse {
    init() {
        transactionId = "T0\(Int.random(in: 9...99999))"
        _type = Int.random(in: 0...1) == 0 ? TransactionType.credit.rawValue : TransactionType.debit.rawValue
        amount = Double.random(in: 10...10000)
        title = ["Carrefour", "ATM", "Starbucks", "McDonald's", "YAP"][Int.random(in: 0...2)]
        currency = "د.إ"
        closingBalance = Double.random(in: 10...10000)
        category = "Retail"
        paymentMode = "Debit Card"
        merchant = "POS"
        transactionNote = ""
        transactionNoteDate = nil
        self.id = Int.random(in: 9...99999)
        date = Date()
        updatedDate = Date()
        card = "125245"
        productName = nil
        totalAmount = Double.random(in: 10...1000)
        status = nil
        openingBalance = Double.random(in: 10...10000)
        _productCode = TransactionProductCode.topUpByExternalCard.rawValue
        senderName = nil
        receiverName = nil
        fee = 0
        vat = 0
        merchantLogoUrl = nil
        merchantName = nil
        merchantCategory = nil
        location = nil
        senderUrl = nil
        receiverUrl = nil
        maskedCardNumber = "12345"
        cancelReason = nil
        cardType = "Prepaid"
        otherBankName = nil
        otherBankBIC = nil
        otherBankBranch = nil
        otherBankCountry = nil
        otherBankCurrency = nil
        fxRate = nil
        settlementAmount = 0
        receiverTransactionNote = nil
        receiverTransactionNoteDate = nil
        cardName1 = nil
        cardName2 = nil
        markupFee = nil
        cardHolderBillingAmount = 0
        virtualCardDesignCode = nil
        beneficiaryId = nil
        senderCustomerId = nil
        _txnState = nil
        cardHolderBillingCurrency = "AED"
        cardHolderBillingTotalAmount = Double.random(in: 10...1000)
        tapixCategory = nil
        latitude = 0.0
        longitude = 0.0
    }
}

extension TransactionResponse {
    init(_ transaction: TransactionResponse, index: Int) {
        transactionId = transaction.transactionId
        _type = transaction._type
        amount = transaction.amount
        title = transaction.title
        currency = transaction.currency
        closingBalance = transaction.closingBalance
        category = transaction.category
        paymentMode = transaction.paymentMode
        merchant = transaction.merchant
        transactionNote = transaction.transactionNote
        transactionNoteDate = transaction.transactionNoteDate
        id = transaction.id
        date = transaction.date
        updatedDate = transaction.updatedDate
        card = transaction.card
        productName = transaction.productName
        totalAmount = transaction.totalAmount
        status = transaction.status
        openingBalance = transaction.openingBalance
        _productCode = transaction._productCode
        senderName = transaction.senderName
        receiverName = transaction.receiverName
        fee = transaction.fee
        vat = transaction.vat
        merchantLogoUrl = transaction.merchantLogoUrl
        merchantName = transaction.merchantName
        merchantCategory = transaction.merchantCategory
        location = transaction.location
        senderUrl = transaction.senderUrl
        receiverUrl = transaction.receiverUrl
        maskedCardNumber = transaction.maskedCardNumber
        cancelReason = transaction.cancelReason
        cardType = transaction.cardType
        otherBankName = transaction.otherBankName
        otherBankBIC = transaction.otherBankBIC
        otherBankBranch = transaction.otherBankBranch
        otherBankCountry = transaction.otherBankCountry
        otherBankCurrency = transaction.otherBankCurrency
        fxRate = transaction.fxRate
        settlementAmount = transaction.settlementAmount
        remarks = transaction.remarks
        customerId = transaction.customerId
        self.index = index
        receiverTransactionNote = transaction.receiverTransactionNote
        receiverTransactionNoteDate = transaction.receiverTransactionNoteDate
        cardName1 = transaction.cardName1
        cardName2 = transaction.cardName2
        markupFee = transaction.markupFee
        cardHolderBillingAmount = transaction.cardHolderBillingAmount
        virtualCardDesignCode = transaction.virtualCardDesignCode
        beneficiaryId = transaction.beneficiaryId
        senderCustomerId = transaction.senderCustomerId
        _txnState = transaction._txnState
        cardHolderBillingCurrency = transaction.cardHolderBillingCurrency
        cardHolderBillingTotalAmount = transaction.cardHolderBillingTotalAmount
        tapixCategory = transaction.tapixCategory
        latitude = transaction.latitude
        longitude = transaction.longitude
    }
}

extension Array where Element == TransactionResponse {
    var indexed: [Element] {
        return filter { $0.receiverUrl == nil || $0.senderUrl == nil || $0.merchantLogoUrl == nil }
            .enumerated().map{ TransactionResponse($0.1, index: $0.0) }
    }
}

extension Array where Element == TransactionResponse {
    var startDates: [Date] {
        return map{  $0.sectionDate }
    }
}

extension TransactionResponse {
//    var numberOfSections: [Int] {
//        var differences = [Int]()
//        for i in 0..<startDates.count - 1 {
//            let dayComponent = Calendar.current.dateComponents([.day], from: startDates[i], to: startDates[i+1])
//            differences.append(dayComponent.day!)
//        }
//        print("differences \(differences)")
//        return differences
//    }
//
    
    struct Section {
        let date: Date
        var transactions: [TransactionResponse]
        
        init(date: Date, transactions: [TransactionResponse]) {
            self.date = date
            self.transactions = transactions
        }
    }
    
    public static func getNumberOfSections(allTransactions transactions: [TransactionResponse], searchText:String? = nil) -> [Section] {
        // var unique = Set<DateComponents>()
        var dictionary = [Date:[TransactionResponse]]()
        
        _ = transactions/*.sorted(by: { $0.date.compare($1.date) == .orderedDescending })*/.map({ transaction -> Void in
            // let comps = Calendar.current.dateComponents([.day, .month, .year], from: transaction.date)
            let existingItems = dictionary[transaction.sectionDate] ?? []
            dictionary[transaction.sectionDate] = [transaction] + existingItems
            return ()
        })
        
        
        var sections = dictionary.sorted(by: {$0.key.timeIntervalSince1970 > $1.key.timeIntervalSince1970}).map{
            Section.init(date: $0.key, transactions: $0.value.sorted(by: {$0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970}))
        }
//        sections.sort(by: {$0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970})
//        sections.map{
//            $0.transactions.sort{}
//        }
        
       /* _ = sections.map {
            print($0.date.string())
            _ = $0.transactions.map{
                print($0.id)
            }
        } */
        /*
        if let text = searchText {
            var newSections = [Section]()
            for section in sections {
                var newTransactions = [TransactionResponse]()
                for transaction in section.transactions {
                    if transaction.title?.lowercased() == text.lowercased() {
                        newTransactions.append(transaction)
                    }
                }
                newSections.append(section)
            }
            sections = newSections
        } */
        
        return sections
    }

    public static func transactions(for section: Int, allTransactions  transactions: [TransactionResponse]) -> [TransactionResponse] {
        let sections = TransactionResponse.getNumberOfSections(allTransactions: transactions)
        guard !sections.isEmpty && section < sections.count else { return [] }
        return sections[section].transactions
    }
    
    static func numberOfTransaction(in section: Int, allTransactions transactions: [TransactionResponse]) -> Int {
        return TransactionResponse.transactions(for: section, allTransactions: transactions).count
    }
    
    static func transaction(for indexPath: IndexPath, allTransactions transactions: [TransactionResponse]) -> TransactionResponse? {
        let transactions = TransactionResponse.transactions(for: indexPath.section, allTransactions: transactions)
        guard indexPath.row < transactions.count else {return nil}
        return transactions[indexPath.row]
    }
    
    /*
    public static func transactions(for section: Int,allTransactions  transactions: [TransactionResponse]) -> [TransactionResponse] {
        let sections = TransactionResponse.getNumberOfSections(allTransactions: transactions).count
        guard sections > 0 && section < sections else { return [] }
        let transactionSections = TransactionResponse.getNumberOfSections(allTransactions: transactions)
        let requiredTransaction = transactionSections[section]
        var requiredTransactions = [TransactionResponse]()
        var result = transactions.filter {
            let comps = $0.sectionDate
            if requiredTransaction.sectionDate == comps { //requiredTransaction.sectionDate == comps {
                requiredTransactions.append($0)
                return true
            }
            return false
        }
        return result
    }
    
    static func numberOfTransaction(in section: Int,allTransactions transactions: [TransactionResponse]) -> Int {
        return TransactionResponse.transactions(for: section, allTransactions: transactions).count
    }
    
    static func transaction(for indexPath: IndexPath,allTransactions transactions: [TransactionResponse]) -> TransactionResponse? {
//        print("indexPath Section \(indexPath.section)")
        guard indexPath.section < TransactionResponse.getNumberOfSections(allTransactions: transactions).count, indexPath.row < TransactionResponse.transactions(for: indexPath.section, allTransactions: transactions).count else { return nil }
        
        
        return transactions[indexPath.row]//transactions.object(at: indexPath)
    }*/
}

