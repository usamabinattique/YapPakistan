//
//  Card.swift
//  YAPPakistan
//
//  Created by Sarmad on 15/11/2021.
//

import Foundation

public enum PaymentCardFeature {
    case everyNeed
    case virtualOrPhysical
    case nickname
    case freezeOrUnfreeze
    case sendSalaries
    case allocateBudget
    case setUpPayments
    case trackExpenses
    case addInstantly
    case onlinePayments
    case funds
    case realTimeExchangeRate
    case freeATMWithdrawls
    case travelInsurance
    case priorityCustomerSupport
    case airportLoungeAccess
    case freePackageSubscription
    case exclusivePartnerOffers
}

public extension PaymentCardFeature {
    var title: String {
        switch self {
        case .everyNeed:
            return "screen_add_card_display_text_feature_spare_card_every_need_title".localized
        case .virtualOrPhysical:
            return "screen_add_card_display_text_feature_spare_card_virtual_or_physical_title".localized
        case .nickname:
            return "screen_add_card_display_text_feature_spare_card_nick_name_title".localized
        case .freezeOrUnfreeze:
            return "screen_add_card_display_text_feature_spare_card_freeze_or_unfreeze_title".localized
        case .sendSalaries:
            return "screen_yap_house_hold_subscription_selection_display_text_benefit_send_salaries".localized
        case .allocateBudget:
            return "screen_yap_house_hold_subscription_selection_display_text_benefit_allocate_budget".localized
        case .setUpPayments:
            return "screen_yap_house_hold_subscription_selection_display_text_benefit_setup_payments".localized
        case .trackExpenses:
            return "screen_yap_house_hold_subscription_selection_display_text_benefit_track_expense".localized
        case .addInstantly:
            return "screen_add_card_display_text_feature_spare_card_add_instantly".localized
        case .onlinePayments:
            return "screen_add_card_display_text_feature_spare_card_online_payments".localized
        case .funds:
            return "screen_add_card_display_text_feature_spare_card_funds".localized
        case .exclusivePartnerOffers:
            return "screen_add_card_display_text_feature_exclusive_partner_offers".localized
        case .realTimeExchangeRate:
            return "screen_add_card_display_text_feature_realtime_exchange_rate".localized
        case.airportLoungeAccess:
            return "screen_add_card_display_text_feature_premier_airport_lounge_access".localized
        case .freeATMWithdrawls:
            return "screen_add_card_display_text_feature_free_atm_withdrawals".localized
        case .priorityCustomerSupport:
            return "screen_add_card_display_text_feature_priority_customer_support".localized
        case .freePackageSubscription:
            return "screen_add_card_display_text_feature_free_package_subscription".localized
        case .travelInsurance:
            return "screen_add_card_display_text_feature_travel_insurance".localized
            
        }
        
    }
    
    var description: String {
        switch self {
        case .everyNeed:
            return "screen_add_card_display_text_feature_spare_card_every_need_details".localized
        case .virtualOrPhysical:
            return "screen_add_card_display_text_feature_spare_card_virtual_or_physical_details".localized
        case .nickname:
            return "screen_add_card_display_text_feature_spare_card_nick_name_details".localized
        case .freezeOrUnfreeze:
            return "screen_add_card_display_text_feature_spare_card_freeze_or_unfreeze_details".localized
        case .sendSalaries:
            return "screen_add_card_display_text_feature_spare_card_every_need_details".localized
        case .allocateBudget:
            return "screen_add_card_display_text_feature_spare_card_virtual_or_physical_details".localized
        case .setUpPayments:
            return "screen_add_card_display_text_feature_spare_card_nick_name_details".localized
        case .trackExpenses:
            return "screen_add_card_display_text_feature_spare_card_freeze_or_unfreeze_details".localized
        case .addInstantly, .funds, .onlinePayments, .exclusivePartnerOffers, .freePackageSubscription, .priorityCustomerSupport, .realTimeExchangeRate, .airportLoungeAccess, .freeATMWithdrawls, .travelInsurance:
            return ""
            
        }
    }
}

struct CardDetails: Codable {
    let cvv2: String?
    let cardToken: String?
    let expiry: String?
    let responseCode: String?

    enum CodingKeys: String, CodingKey {
        case cvv2, cardToken, expiry, responseCode
    }

    init(from decoder: Decoder) throws {
        let values = try? decoder.container(keyedBy: CodingKeys.self)
        cvv2 = try? values?.decodeIfPresent(String.self, forKey: .cvv2)
        cardToken = try? values?.decodeIfPresent(String.self, forKey: .cardToken)
        expiry = try? values?.decodeIfPresent(String.self, forKey: .expiry)
        responseCode = try? values?.decodeIfPresent(String.self, forKey: .responseCode)
    }
}

public class PaymentCard: Codable {
    
    internal init(accountNumber: String?, accountType: String?, active: Bool?, atmAllowed: Bool? = nil, availableBalance: Double?, backImage: String? = nil, blocked: Bool? = nil, cardBalance: Double?, cardName: String? = nil, cardScheme: String?, cardSerialNumber: String?, cardType: PaymentCardType, currentBalance: Double?, customerId: String?, delivered: Bool?, deliveryStatus: PaymentCard.DeliveryStatus, expiryDate: String?, frontImage: String?, issuanceDate: String?, maskedCardNo: String?, nameUpdated: Bool?, onlineBankingAllowed: Bool?, paymentAbroadAllowed: Bool?, physical: Bool, pinCreated: Bool?, pinStatus: PaymentCard.PinStatus?, productCode: String?, retailPaymentAllowed: Bool? = nil, shipmentStatus: String?, status: CardStatus?, uuid: String?, cardDetails: CardDetails? = nil) {
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.active = active
        self.atmAllowed = atmAllowed
        self.availableBalance = availableBalance
        self.backImage = backImage
        self.blocked = blocked
        self.cardBalance = cardBalance
        self.cardName = cardName
        self.cardScheme = cardScheme
        self.cardSerialNumber = cardSerialNumber
        self.cardType = cardType
        self.currentBalance = currentBalance
        self.customerId = customerId
        self.delivered = delivered
        self.deliveryStatus = deliveryStatus
        self.expiryDate = expiryDate
        self.frontImage = frontImage
        self.issuanceDate = issuanceDate
        self.maskedCardNo = maskedCardNo
        self.nameUpdated = nameUpdated
        self.onlineBankingAllowed = onlineBankingAllowed
        self.paymentAbroadAllowed = paymentAbroadAllowed
        self.physical = physical
        self.pinCreated = pinCreated
        self.pinStatus = pinStatus
        self.productCode = productCode
        self.retailPaymentAllowed = retailPaymentAllowed
        self.shipmentStatus = shipmentStatus
        self.status = status
        self.uuid = uuid
        self.cardDetails = cardDetails
    }
    
    let accountNumber: String?
    let accountType: String?
    let active: Bool?
    var atmAllowed: Bool?
    let availableBalance: Double?
    var backImage: String?
    var blocked: Bool?
    let cardBalance: Double?
    var cardName: String?
    let cardScheme: String?
    let cardSerialNumber: String?
    let cardType: PaymentCardType
    let currentBalance: Double?
    let customerId: String?
    let delivered: Bool?
    var deliveryStatus: DeliveryStatus
    let expiryDate: String?
    let frontImage: String?
    let issuanceDate: String?
    let maskedCardNo: String?
    let nameUpdated: Bool?
    let onlineBankingAllowed: Bool?
    let paymentAbroadAllowed: Bool?
    let physical: Bool
    let pinCreated: Bool?
    var pinStatus: PinStatus?
    let productCode: String?
    var retailPaymentAllowed: Bool?
    let shipmentStatus: String?
    let status: CardStatus?
    let uuid: String?
    var cardDetails: CardDetails?
    var deliveryDate: Date?
    var setPinDate: Date?
    var pinSet: Bool?
   

    enum CodingKeys: String, CodingKey {
        case accountNumber, accountType, active, atmAllowed, availableBalance, backImage, blocked, cardBalance,
             cardName, cardScheme, cardSerialNumber, cardType, currentBalance, customerId, delivered, deliveryStatus,
             expiryDate, frontImage, issuanceDate, maskedCardNo, nameUpdated, onlineBankingAllowed,
             paymentAbroadAllowed, physical, pinCreated, pinStatus, productCode, retailPaymentAllowed,
             shipmentStatus, status, uuid, setPinDate, pinSet
        case deliveryDate = "shipmentDate"
    }

    required public init(from decoder: Decoder) throws {
        let values = try? decoder.container(keyedBy: CodingKeys.self)
        accountNumber = try? values?.decodeIfPresent(String.self, forKey: .accountNumber)
        accountType = try? values?.decodeIfPresent(String.self, forKey: .accountType)
        active = try? values?.decodeIfPresent(Bool.self, forKey: .active)
        atmAllowed = try? values?.decodeIfPresent(Bool.self, forKey: .atmAllowed)
        availableBalance = try? values?.decodeIfPresent(Double.self, forKey: .availableBalance)
        backImage = try? values?.decodeIfPresent(String.self, forKey: .backImage)
        blocked = try? values?.decodeIfPresent(Bool.self, forKey: .blocked)
        cardBalance = try? values?.decodeIfPresent(Double.self, forKey: .cardBalance)
        cardName = try? values?.decodeIfPresent(String.self, forKey: .cardName)
        cardScheme = try? values?.decodeIfPresent(String.self, forKey: .cardScheme)
        cardSerialNumber = try? values?.decodeIfPresent(String.self, forKey: .cardSerialNumber)
        cardType = (try? values?.decodeIfPresent(PaymentCardType.self, forKey: .cardType)) ?? .debit
        currentBalance = try? values?.decodeIfPresent(Double.self, forKey: .currentBalance)
        customerId = try? values?.decodeIfPresent(String.self, forKey: .customerId)
        delivered = try? values?.decodeIfPresent(Bool.self, forKey: .delivered)
        deliveryStatus = (try? values?.decodeIfPresent(DeliveryStatus.self, forKey: .deliveryStatus)) ?? .ordered
        expiryDate = try? values?.decodeIfPresent(String.self, forKey: .expiryDate)
        frontImage = try? values?.decodeIfPresent(String.self, forKey: .frontImage)
        issuanceDate = try? values?.decodeIfPresent(String.self, forKey: .issuanceDate)
        maskedCardNo = try? values?.decodeIfPresent(String.self, forKey: .maskedCardNo)
        nameUpdated = try? values?.decodeIfPresent(Bool.self, forKey: .nameUpdated)
        onlineBankingAllowed = try? values?.decodeIfPresent(Bool.self, forKey: .onlineBankingAllowed)
        paymentAbroadAllowed = try? values?.decodeIfPresent(Bool.self, forKey: .paymentAbroadAllowed)
        physical = ((try? values?.decodeIfPresent(Bool.self, forKey: .physical)) != nil)
        pinCreated = try? values?.decodeIfPresent(Bool.self, forKey: .pinCreated)
        pinSet = try? values?.decodeIfPresent(Bool.self, forKey: .pinSet)
        pinStatus = try? values?.decodeIfPresent(PinStatus.self, forKey: .pinStatus)
        productCode = try? values?.decodeIfPresent(String.self, forKey: .productCode)
        retailPaymentAllowed = try? values?.decodeIfPresent(Bool.self, forKey: .retailPaymentAllowed)
        shipmentStatus = try? values?.decodeIfPresent(String.self, forKey: .shipmentStatus)
        status = try? values?.decodeIfPresent(CardStatus.self, forKey: .status)
        uuid = try? values?.decodeIfPresent(String.self, forKey: .uuid)
        
        deliveryDate = try? (values?.decodeIfPresent(String.self, forKey: .deliveryDate).map { DateFormatter.transactionDateFormatter.date(from: $0) }) ?? nil
        setPinDate = try? (values?.decodeIfPresent(String.self, forKey: .setPinDate).map { DateFormatter.transactionDateFormatter.date(from: $0) }) ?? nil
    }
}

extension PaymentCard {
    enum DeliveryStatus: String, Codable {
        case ordered = "ORDERED"  // 3 Not comming from backend? This is to represent statatus;
        case shipped = "SHIPPED"      // 3
        case delivered = "DELIVERED"    // 2
        case failed = "FAILED"          //
    }

    enum Status: String, Codable {
        case active = "ACTIVE"
        case blocked = "BLOCKED"
        case inActive = "INACTIVE"
        case hotlisted = "HOTLISTED"
        case expired = "EXPIRED"
    }

    enum PinStatus: String, Codable {
        case inActive = "INACTIVE"
        case blocked = "BLOCKED"
        case active = "ACTIVE"
    }
}

public enum PaymentCardPlan: String, Codable {
    case spare = "SPARE"
    case premium = "PREMIUM"
    case metal = "METAL"
    
    public var toString: String {
        get {
            return rawValue.prefix(1).uppercased() + rawValue.dropFirst().lowercased() + " card"
        }
    }
    
    public var toLowerCase: String {
        get {
            return rawValue.prefix(1).uppercased() + rawValue.dropFirst().lowercased()
        }
    }
    
//    public var colors: [YAPCard] {
//        get {
//            switch self {
//            case .premium:
//                return [.premiumRoseGold, .premiumGold, .premiumGrey, .premiumBlack ]
//            case .metal:
//                return [.metalRoseGold, .metalGrey, .metalBlack]
//            case .spare:
//                return [.virtualDarkBlue, .virtualGreen, .virtualMulti, .virtualLightBlue, .virtualPurple]
//                
//            }
//        }
//    }
    
    public var features : [PaymentCardFeature] {
        get {
            switch self {
            case .premium:
                return [.realTimeExchangeRate, .freeATMWithdrawls, .travelInsurance, .priorityCustomerSupport, .airportLoungeAccess, .freePackageSubscription ]
            case .metal:
                return [.exclusivePartnerOffers, .realTimeExchangeRate, .freeATMWithdrawls, .travelInsurance, .priorityCustomerSupport, .airportLoungeAccess, .freePackageSubscription ]
            case .spare:
                return [.addInstantly, .onlinePayments, .funds, .nickname, .freezeOrUnfreeze]
            }
        }
    }
    
    public var badge: UIImage? {
         switch self {
         case .premium:
             return UIImage(named: "icon_gold_badge", in: .yapPakistan)
         case .metal:
             return UIImage(named: "icon_black_badge", in: .yapPakistan)
         case .spare:
             return UIImage(named: "icon_primary_badge", in: .yapPakistan)
         }
     }
    
}

public enum PaymentCardBlockOption: String, Codable {
    case damage = "4"
    case lostOrStolen = "2"
}

public enum PaymentCardType: String, Codable {
    case debit = "DEBIT"
    case prepaid = "PREPAID"
}

extension PaymentCardType: Comparable {
    public static func < (lhs: PaymentCardType, rhs: PaymentCardType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    var localizedString: String {
        switch self {
        case .debit:
            return "Debit"
        case .prepaid:
            return "Virtual"
        }
    }
}

public enum CardStatus: String, Codable {
    case active = "ACTIVE"
    case blocked = "BLOCKED"
    case inActive = "INACTIVE"
    case hotlisted = "HOTLISTED"
    case expired = "EXPIRED"
    case closed = "CLOSED"
    case cancelled = "CANCELLED"
    
}

public extension CardStatus {
    var leaplumStatus: String {
        switch self {
        case .active:
            return "active"
        case .blocked:
            return "frozen"
        case .inActive:
            return "in-active"
        case .hotlisted:
            return "hotlisted"
        case .expired:
            return "expired"
        case .closed:
            return "closed"
        case .cancelled:
            return "expired"
        }
    }
}

extension PaymentCard: StatementFetchable {
    public var idForStatements: String? {
        return self.cardSerialNumber
    }
    
    public var statementType: StatementType { .card }
}

extension PaymentCard {
    public static var mock: PaymentCard {
        PaymentCard(accountNumber: nil, accountType: nil, active: nil, atmAllowed: nil, availableBalance: nil, backImage: nil, blocked: nil, cardBalance: nil, cardName: nil, cardScheme: nil, cardSerialNumber: nil, cardType: PaymentCardType.debit, currentBalance: nil, customerId: nil, delivered: nil, deliveryStatus: .ordered, expiryDate: nil, frontImage: nil, issuanceDate: nil, maskedCardNo: nil, nameUpdated: nil, onlineBankingAllowed: nil, paymentAbroadAllowed: nil, physical: false, pinCreated: nil, pinStatus: nil, productCode: nil, retailPaymentAllowed: nil, shipmentStatus: nil, status: nil, uuid: nil, cardDetails: nil)
    }
    
}
