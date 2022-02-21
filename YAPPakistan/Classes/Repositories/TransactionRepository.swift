//
//  TransactionRepository.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 27/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
// import Networking
import RxSwift

protocol TransactionsRepositoryType {
    func fetchTransactions(
        pageNumber: Int,
        pageSize: Int,
        minAmount: Double?,
        maxAmount: Double?,
        creditSearch: Bool?,
        debitSearch: Bool?,
        yapYoungTransfer: Bool?
    ) -> Observable<Event<PagableResponse<TransactionResponse>>>

    func fetchCardTransactions(
        pageNo: Int,
        pageSize: Int,
        cardSerialNo: String,
        debitSearch: Bool, filter: TransactionFilter?
    ) -> Observable<Event<PagableResponse<TransactionResponse>>>
    
    func getTransactionLimit() -> Observable<Event<TransactionFilterAmountRange>>
    func fetchCheckoutSession(orderId: String, amount: String, currency: String, sessionId: String) -> Observable<Event<PaymentGatewayCheckoutSession>>
    func paymentGatewayTopup(orderID: String, beneficiaryID: Int, amount: String, currency: String, securityCode: String, threeDSecureID: String) -> Observable<Event<Int?>>
}

class TransactionsRepository: TransactionsRepositoryType {

    private let transactionService: TransactionsService

    init(transactionService: TransactionsService) {
        self.transactionService = transactionService
    }

    func fetchTransactions(
        pageNumber: Int,
        pageSize: Int,
        minAmount: Double?,
        maxAmount: Double?,
        creditSearch: Bool?,
        debitSearch: Bool?,
        yapYoungTransfer: Bool?
    ) -> Observable<Event<PagableResponse<TransactionResponse>>> {
        return transactionService.fetchTransactions(
            pageNumber: pageNumber,
            pageSize: pageSize,
            minAmount: minAmount,
            maxAmount: maxAmount,
            creditSearch: creditSearch,
            debitSearch: debitSearch,
            yapYoungTransfer: yapYoungTransfer
        ).materialize()
    }

    func fetchCardTransactions(
        pageNo: Int,
        pageSize: Int,
        cardSerialNo: String,
        debitSearch: Bool = false, filter: TransactionFilter? = nil
    ) -> Observable<Event<PagableResponse<TransactionResponse>>> {
        return transactionService.fetchCardTransactions(cardSerialNumber: cardSerialNo, pageNumber: pageNo, pageSize: pageSize, debitSearch: debitSearch, filter: filter).materialize()
    }
    
    func getTransactionLimit() -> Observable<Event<TransactionFilterAmountRange>> {
        return transactionService.getTransactionFilters().materialize()
    }
    
    func fetchCheckoutSession(orderId: String, amount: String, currency: String, sessionId: String) -> Observable<Event<PaymentGatewayCheckoutSession>> {
        return transactionService.createCheckoutSession(orderId: orderId, amount: amount, currency: currency, sessionId: sessionId).materialize()
    }
    
    func fetch3DSEnrollment(orderId: String, beneficiaryID: Int, amount: String, currency: String, sessionID: String) -> Observable<Event<PaymentGateway3DSEnrollmentResult>> {
        return transactionService.check3DSEnrollment(orderId: orderId, beneficiaryID: beneficiaryID, amount: amount, currency: currency, sessionID: sessionID).materialize()
    }
    
    func retrieveACSResults(threeDSecureID: String) -> Observable<Event<String?>> {
        return transactionService.retrieveACSResults(threeDSecureID: threeDSecureID).materialize()
    }
    
    public func paymentGatewayTopup(orderID: String, beneficiaryID: Int, amount: String, currency: String, securityCode: String, threeDSecureID: String) -> Observable<Event<Int?>> {
        return transactionService.paymentGatewayTopup(orderID: orderID, beneficiaryID: beneficiaryID, amount: amount, currency: currency, securityCode: securityCode, threeDSecureID: threeDSecureID).materialize()
    }
}

/*
 class TransactionsRepository: YAPRepository {
    

    
    func fetchTransactionDetails(transactionId: String) -> Observable<Event<TransactionDetails>> {
        return transactionService.fetchTransactionDetails(transactionId: transactionId).materialize()
    }
    
    func addNote(transactionId: String, senderTransactionNote: String?, receiverTransactionNote: String?) -> Observable<Event<String?>> {
        return transactionService.addNote(transactionId: transactionId, senderTransactionNote: senderTransactionNote, receiverTransactionNote: receiverTransactionNote).materialize()
    }
    
    func fetchCardTransactions(pageNo: Int, pageSize: Int, cardSerialNo: String, debitSearch: Bool = false) -> Observable<Event<PagableResponse<TransactionResponse>>> {
        return transactionService.getCardTransactions(cardSerialNumber: cardSerialNo, pageNumber: pageNo, pageSize: pageSize, debitSearch: debitSearch).materialize()
    }
    
    func getDenominationAmount(productCode: String) -> Observable<Event<[DenominationResponse]>> {
        return transactionService.getDenominationAmount(productCode: productCode).materialize()
    }
    
    func getProductLimit() -> Observable<Event<ProductLimit>> {
        return transactionService.getProductLimit().materialize()
    }
    
    func subCardTopup(amount: String, cardSerial: String) -> Observable<Event<AddRemoveFundsResponse>> {
        return transactionService.performSubCardTopUp(amount, toCard: cardSerial).materialize()
    }
    
    func subCardWithdraw(amount: String, cardSerial: String) -> Observable<Event<AddRemoveFundsResponse>> {
        return transactionService.performSubCardWithdraw(amount, fromCard: cardSerial).materialize()
    }
    
    func getWithdrawProductLimit() -> Observable<Event<ProductLimit>> {
        return transactionService.getWithdrawProductLimits().materialize()
    }
    
    func getTransactionLimit() -> Observable<Event<TransactionFilterAmountRange>> {
        return transactionService.getTransactionFilters().materialize()
    }
    
    func getTopupTransactionFee(productName: String) -> Observable<Event<TransferFee?>> {
        return transactionService.getFee(productCode: productName).materialize()
    }
    
    func getTransactionProductLimit(transactionProductCode: String) -> Observable<Event<ProductLimit>> {
        return transactionService.getTransactionProductLimit(transactionProductCode: transactionProductCode).materialize()
    }
    
    func sendHouseholdPayment(to uuid: String, amount: String, remarks: String, beneficiaryName: String)  -> Observable<Event<HouseholdPayNow?>> {
        return transactionService.sendHouseholdPayment(to: uuid, amount: amount, remarks: remarks, beneficiaryName: beneficiaryName).materialize()
    }
    
    func addReceiptPhoto(_ transactionId: String, _ data: Data, _ name: String, _ fileName: String, _ mimeType: String) -> Observable<Event<String?>> {
        return transactionService.uploadReceiptPhoto(transactionId: transactionId, data: data, name: name, fileName: fileName, mimeType: mimeType, progressObserver: nil).materialize()
    }
    
    func getAllReceipts(_ transactionId: String) -> Observable<Event<[String]?>>{
        return transactionService.getAllReceipts(transactionId).materialize()
    }
    
    func deleteReceipt(_ transactionId: String, imageName: String) -> Observable<Event<String?>>{
        return transactionService.deleteReceipts(transactionId, imageName: imageName).materialize()
    }
    
    func fetchTotalPurchaseData(transactionType: String, beneficiaryId: String?, receiverCustomerId: String?, productCode: String, merchantName: String?, senderCustomerId: String?) -> Observable<Event<TotalPurchase>>{
        return transactionService.fetchTotalPurchaseData(transactionType: transactionType, beneficiaryId: beneficiaryId, receiverCustomerId: receiverCustomerId, productCode: productCode, merchantName: merchantName, senderCustomerId: senderCustomerId).materialize()
    }
    
    func getTapixCategories() -> Observable<Event<[TapixTransactionCategory]>> {
        transactionService.getAllTransactionCategories().materialize()
    }
    
    func updateTransactionCategory(transactionId: String, categoryId: String) -> Observable<Event<String?>> {
        transactionService.updateTransactionCategory(transactionId: transactionId, categoryId: categoryId).materialize()
    }
    
    func emailStatement(request: EmailStatement ) -> Observable<Event<String?>>{
        transactionService.emailStatement(url: request.url?.absoluteString ?? "", month: request.month ?? "", year: request.year ?? "", statementType: request.statementType ?? "").materialize()
    }
}
*/
