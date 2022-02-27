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
    func fetchCheckoutSession(amount: String, currency: String, sessionId: String) ->  Observable<Event<PaymentGatewayCheckoutSession>>
    func paymentGatewayTopup(threeDSecureId: String, orderId: String, currency: String, amount: String, sessionId: String) -> Observable<Event<String?>>
    func createCardHolder(cardScheme: String, fee: String) -> Observable<Event<String?>>
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
    
    func fetchCheckoutSession(amount: String, currency: String, sessionId: String) -> Observable<Event<PaymentGatewayCheckoutSession>> {
        return transactionService.createCheckoutSession(amount: amount, currency: currency, sessionId: sessionId).materialize()
    }
    
    func fetch3DSEnrollment(orderId: String, beneficiaryID: Int, amount: String, currency: String, sessionID: String) -> Observable<Event<PaymentGateway3DSEnrollmentResult>> {
        return transactionService.check3DSEnrollment(orderId: orderId, beneficiaryID: beneficiaryID, amount: amount, currency: currency, sessionID: sessionID).materialize()
    }
    
    func retrieveACSResults(threeDSecureID: String) -> Observable<Event<String?>> {
        return transactionService.retrieveACSResults(threeDSecureID: threeDSecureID).materialize()
    }
    
    public func paymentGatewayTopup(threeDSecureId: String, orderId: String, currency: String, amount: String, sessionId: String) -> Observable<Event<String?>> {
        return transactionService.paymentGatewayTopup(threeDSecureId: threeDSecureId, orderId: orderId, currency: currency, amount: amount, sessionId: sessionId).materialize()
    }
    
    public func createCardHolder(cardScheme: String, fee: String) -> Observable<Event<String?>> {
        return transactionService.createCardHolder(cardScheme: cardScheme, fee: fee).materialize()
    }
}
