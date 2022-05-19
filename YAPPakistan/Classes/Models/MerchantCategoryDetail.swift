//
//  MerchantCategoryDetail.swift
//  YAPPakistan
//
//  Created by Yasir on 16/05/2022.
//


import Foundation

// MARK: - Welcome
struct MerchantCategoryDetail: Codable {
    let currentToLastMonth: Double
    let averageSpending: Double
    let transactionDetails: [TransactionResponse]
}

extension MerchantCategoryDetail {
    static var mocked: MerchantCategoryDetail = MerchantCategoryDetail(currentToLastMonth: 50, averageSpending: 80, transactionDetails: [TransactionResponse.init(), TransactionResponse.init(), TransactionResponse.init(), TransactionResponse.init(), TransactionResponse.init(), TransactionResponse.init(), TransactionResponse.init(), TransactionResponse.init(), TransactionResponse.init(), TransactionResponse.init(), TransactionResponse.init(), TransactionResponse.init()])
}

//MARK: Transaction

struct AnalyticsTransaction: Codable {
    let fromCard, fromIBAN, productName, category: String
    let txnType: String
    let amount, totalAmount: Double
    let currency, txnState, status: String
    let fromBalanceBefore, fromBalanceAfter: Double
    let merchantName, merchantCode, merchantCategory, merchantCategoryName: String
    let merchantLogo, remarks, productCode, fromAccountUUID: String
    let initiator, processorRefNumber, transactionID, fromCustomerID: String
    let senderMobileNo, senderEmail, senderName, maskedCardNo: String
    let terminalID: String
    let settlementAmount: Int
    let settlementCurrency, cardHolderBillingCurrency: String
    let cardHolderBillingAmount: Double
    let cardAcceptorLocation: String
    let otpVerificationReq: Bool
    let createdBy, creationDate, paymentMode, fromUserType: String
    let title, updatedDate, updatedBy: String
    let count, feeAmount, markUp, vat: Int
    let cardType: String
    let postedFees: Int
    let cbwsi, cbwsiFee, nonChargeable: Bool
    let timeZone: String
    let bankCBWISCompliant, reversibleOnTimeout, skipProductLimits: Bool
    let currencyDecimalScale, vatPercentage: Int
    let forcePostReq, reversal, dispute, approved: Bool

    enum CodingKeys: String, CodingKey {
        case fromCard, fromIBAN, productName, category, txnType, amount, totalAmount, currency, txnState, status, fromBalanceBefore, fromBalanceAfter, merchantName, merchantCode, merchantCategory, merchantCategoryName, merchantLogo, remarks, productCode, fromAccountUUID, initiator, processorRefNumber
        case transactionID = "transactionId"
        case fromCustomerID = "fromCustomerId"
        case senderMobileNo, senderEmail, senderName, maskedCardNo
        case terminalID = "terminalId"
        case settlementAmount, settlementCurrency, cardHolderBillingCurrency, cardHolderBillingAmount, cardAcceptorLocation, otpVerificationReq, createdBy, creationDate, paymentMode, fromUserType, title, updatedDate, updatedBy, count, feeAmount, markUp, vat, cardType, postedFees, cbwsi, cbwsiFee, nonChargeable, timeZone, bankCBWISCompliant, reversibleOnTimeout, skipProductLimits, currencyDecimalScale, vatPercentage, forcePostReq, reversal, dispute, approved
    }
}


