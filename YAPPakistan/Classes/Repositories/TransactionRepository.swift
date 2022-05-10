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
        yapYoungTransfer: Bool?,
        searchText: String?
    ) -> Observable<Event<PagableResponse<TransactionResponse>>>

    func fetchCardTransactions(
        pageNo: Int,
        pageSize: Int,
        cardSerialNo: String,
        debitSearch: Bool, filter: TransactionFilter?
    ) -> Observable<Event<PagableResponse<TransactionResponse>>>
    
    func getTransactionLimit() -> Observable<Event<TransactionFilterAmountRange>>
    func fetchCheckoutSession(beneficiaryId: String, amount: String, currency: String, sessionId: String) -> Observable<Event<PaymentGatewayCheckoutSession>>
    func fetch3DSEnrollment(orderId: String, beneficiaryID: Int, amount: String, currency: String, sessionID: String) -> Observable<Event<PaymentGateway3DSEnrollmentResult>>
    func retrieveACSResults(threeDSecureID: String) -> Observable<Event<String?>>
    func paymentGatewayFirstCreditTopup(threeDSecureId: String, orderId: String, currency: String, amount: String, sessionId: String, securityCode: String, beneficiaryId: String) -> Observable<Event<Account?>>
    func paymentGatewayTopup(threeDSecureId: String, orderId: String, currency: String, amount: String, sessionId: String, securityCode: String, beneficiaryId: String) -> Observable<Event<String?>>
    func createCardHolder(cardScheme: String, fee: String) -> Observable<Event<String?>>
    func fetchCustomerAccountBalance() -> Observable<Event<CustomerBalanceResponse>>
    func getFee(productCode: String) -> Observable<Event<TransactionProductCodeFeeResponse>>
    func getTransactionProductLimit(transactionProductCode: String) -> Observable<Event<TransactionLimit>>
    func getThresholdLimits() -> Observable<Event<TransactionThreshold>>
    func getDenominationAmount(productCode: String) -> Observable<Event<[DenominationResponse]>>
}

class TransactionsRepository: TransactionsRepositoryType {

    private let transactionService: TransactionsService
    private let customersService: CustomersService

    init(transactionService: TransactionsService, customersService: CustomersService) {
        self.transactionService = transactionService
        self.customersService = customersService
    }

    func fetchTransactions(
        pageNumber: Int,
        pageSize: Int,
        minAmount: Double?,
        maxAmount: Double?,
        creditSearch: Bool?,
        debitSearch: Bool?,
        yapYoungTransfer: Bool?,
        searchText: String? = nil
    ) -> Observable<Event<PagableResponse<TransactionResponse>>> {
        return transactionService.fetchTransactions(
            pageNumber: pageNumber,
            pageSize: pageSize,
            minAmount: minAmount,
            maxAmount: maxAmount,
            creditSearch: creditSearch,
            debitSearch: debitSearch,
            yapYoungTransfer: yapYoungTransfer,
            searchText: searchText
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
    
    func fetchCheckoutSession(beneficiaryId: String, amount: String, currency: String, sessionId: String) -> Observable<Event<PaymentGatewayCheckoutSession>> {
        return transactionService.createCheckoutSession(beneficiaryId: beneficiaryId, amount: amount, currency: currency, sessionId: sessionId).materialize()
    }
    
    func fetch3DSEnrollment(orderId: String, beneficiaryID: Int, amount: String, currency: String, sessionID: String) -> Observable<Event<PaymentGateway3DSEnrollmentResult>> {
        return transactionService.check3DSEnrollment(orderId: orderId, beneficiaryID: beneficiaryID, amount: amount, currency: currency, sessionID: sessionID).materialize()
    }
    
    func retrieveACSResults(threeDSecureID: String) -> Observable<Event<String?>> {
        return transactionService.retrieveACSResults(threeDSecureID: threeDSecureID).materialize()
    }
    
    public func paymentGatewayFirstCreditTopup(threeDSecureId: String, orderId: String, currency: String, amount: String, sessionId: String, securityCode: String, beneficiaryId: String) -> Observable<Event<Account?>> {
        return transactionService.paymentGatewayFirstCreditTopup(threeDSecureId: threeDSecureId, orderId: orderId, currency: currency, amount: amount, sessionId: sessionId, securityCode: securityCode, beneficiaryId: beneficiaryId).materialize()
    }
    
    public func paymentGatewayTopup(threeDSecureId: String, orderId: String, currency: String, amount: String, sessionId: String, securityCode: String, beneficiaryId: String) -> Observable<Event<String?>> {
        return transactionService.paymentGatewayTopup(threeDSecureId: threeDSecureId, orderId: orderId, currency: currency, amount: amount, sessionId: sessionId, securityCode: securityCode, beneficiaryId: beneficiaryId).materialize()
    }
    
    public func createCardHolder(cardScheme: String, fee: String) -> Observable<Event<String?>> {
        return transactionService.createCardHolder(cardScheme: cardScheme, fee: fee).materialize()
    }
    
    public func fetchCustomerAccountBalance() -> Observable<Event<CustomerBalanceResponse>> {
//        Observable.create { observer in
//            observer.onNext(.mock)
//            return Disposables.create()
//        }.materialize()
        return customersService.fetchCustomerAccountBalance().materialize()
    }
    
    public func getFee(productCode: String) -> Observable<Event<TransactionProductCodeFeeResponse>> {
        return transactionService.getFee(productCode: productCode).materialize()
    }
    
    public func getTransactionProductLimit(transactionProductCode: String) -> Observable<Event<TransactionLimit>> {
        transactionService.getTransactionProductLimit(transactionProductCode: transactionProductCode).materialize()
    }
    
    public func getThresholdLimits() -> Observable<Event<TransactionThreshold>> {
        return transactionService.getThresholdLimits().materialize()
    }
    
    public func getDenominationAmount(productCode: String) -> Observable<Event<[DenominationResponse]>> {
        return transactionService.getDenominationAmount(productCode: productCode).materialize()
    }
}
