//
//  Card.swift
//  YAPPakistan
//
//  Created by Sarmad on 15/11/2021.
//

import Foundation

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

class PaymentCard: Codable {
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
    let cardType: String?
    let currentBalance: Double?
    let customerId: String?
    let delivered: Bool?
    let deliveryStatus: DeliveryStatus
    let expiryDate: String?
    let frontImage: String?
    let issuanceDate: String?
    let maskedCardNo: String?
    let nameUpdated: Bool?
    let onlineBankingAllowed: Bool?
    let paymentAbroadAllowed: Bool?
    let physical: Bool?
    let pinCreated: Bool?
    let pinStatus: PinStatus?
    let productCode: String?
    var retailPaymentAllowed: Bool?
    let shipmentStatus: String?
    let status: Status?
    let uuid: String?
    var cardDetails: CardDetails?

    enum CodingKeys: String, CodingKey {
        case accountNumber, accountType, active, atmAllowed, availableBalance, backImage, blocked, cardBalance,
             cardName, cardScheme, cardSerialNumber, cardType, currentBalance, customerId, delivered, deliveryStatus,
             expiryDate, frontImage, issuanceDate, maskedCardNo, nameUpdated, onlineBankingAllowed,
             paymentAbroadAllowed, physical, pinCreated, pinStatus, productCode, retailPaymentAllowed,
             shipmentStatus, status, uuid
    }

    required init(from decoder: Decoder) throws {
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
        cardType = try? values?.decodeIfPresent(String.self, forKey: .cardType)
        currentBalance = try? values?.decodeIfPresent(Double.self, forKey: .currentBalance)
        customerId = try? values?.decodeIfPresent(String.self, forKey: .customerId)
        delivered = try? values?.decodeIfPresent(Bool.self, forKey: .delivered)
        deliveryStatus = (try? values?.decodeIfPresent(DeliveryStatus.self, forKey: .deliveryStatus)) ?? .ordering
        expiryDate = try? values?.decodeIfPresent(String.self, forKey: .expiryDate)
        frontImage = try? values?.decodeIfPresent(String.self, forKey: .frontImage)
        issuanceDate = try? values?.decodeIfPresent(String.self, forKey: .issuanceDate)
        maskedCardNo = try? values?.decodeIfPresent(String.self, forKey: .maskedCardNo)
        nameUpdated = try? values?.decodeIfPresent(Bool.self, forKey: .nameUpdated)
        onlineBankingAllowed = try? values?.decodeIfPresent(Bool.self, forKey: .onlineBankingAllowed)
        paymentAbroadAllowed = try? values?.decodeIfPresent(Bool.self, forKey: .paymentAbroadAllowed)
        physical = try? values?.decodeIfPresent(Bool.self, forKey: .physical)
        pinCreated = try? values?.decodeIfPresent(Bool.self, forKey: .pinCreated)
        pinStatus = try? values?.decodeIfPresent(PinStatus.self, forKey: .pinStatus)
        productCode = try? values?.decodeIfPresent(String.self, forKey: .productCode)
        retailPaymentAllowed = try? values?.decodeIfPresent(Bool.self, forKey: .retailPaymentAllowed)
        shipmentStatus = try? values?.decodeIfPresent(String.self, forKey: .shipmentStatus)
        status = try? values?.decodeIfPresent(Status.self, forKey: .status)
        uuid = try? values?.decodeIfPresent(String.self, forKey: .uuid)
    }
}

extension PaymentCard {
    enum DeliveryStatus: String, Codable {
        case shipped = "SHIPPED"    // 4
        case shipping = "SHIPPING"  // 3 Not comming from backend? This is to represent statatus;
        case booked = "BOOKED"      // 3
        case ordered = "ORDERED"    // 2
        case ordering = "ORDERING"  // 1 // Not comming from backend; This is to represent KYC incomplete statatus;
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
