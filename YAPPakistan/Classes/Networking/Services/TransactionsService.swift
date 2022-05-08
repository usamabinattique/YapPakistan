//
//  TransactionsService.swift
//  YAP
//
//  Created by Muhammad Hassan on 15/05/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import RxSwift
import UIKit

protocol TransactionsServiceType {

    func fetchTransactions<T>(pageNumber: Int, pageSize: Int, minAmount: Double?, maxAmount: Double?, creditSearch: Bool?, debitSearch: Bool?, yapYoungTransfer: Bool?) -> Observable<T> where T : Decodable, T : Encodable

    func fetchCardTransactions<T>(cardSerialNumber: String, pageNumber: Int, pageSize: Int, debitSearch: Bool, filter: TransactionFilter?) -> Observable<T> where T : Decodable, T : Encodable

    func fetchReorderFee<T>() -> Observable<T> where T : Decodable, T : Encodable
    
    func getTransactionFilters<T: Codable>() -> Observable<T>
    func getFee<T: Codable>(productCode: String) -> Observable<T>
    func getTransactionProductLimit<T: Codable>(transactionProductCode: String) -> Observable<T>
    func getThresholdLimits<T: Codable>() -> Observable<T>
    func getDenominationAmount<T: Codable>(productCode: String) -> Observable<T>
    func createCheckoutSession<T: Codable>(beneficiaryId: String, amount: String, currency: String, sessionId: String) -> Observable<T>
    func check3DSEnrollment<T: Codable>(orderId: String, beneficiaryID: Int, amount: String, currency: String, sessionID: String) -> Observable<T>
    func retrieveACSResults<T: Codable>(threeDSecureID: String) -> Observable<T>
    func createCardHolder<T: Codable>(cardScheme: String, fee: String) -> Observable<T>
    func paymentGatewayFirstCreditTopup<T: Codable>(threeDSecureId: String, orderId: String, currency: String, amount: String, sessionId: String, securityCode: String, beneficiaryId: String) -> Observable<T>
    func paymentGatewayTopup<T: Codable>(threeDSecureId: String, orderId: String, currency: String, amount: String, sessionId: String, securityCode: String, beneficiaryId: String) -> Observable<T>
    func fetchTransferReasons<T: Codable>() -> Observable<T>
    func sendMoneyViaBankTransfer<T: Codable>(input: SendMoneyBankTransferInput) -> Observable<T>
    func cardStatement<T: Codable>(_ cardSerialNumber: String) -> Observable<T>
    func cardCustomStatement<T: Codable>(_ cardSerialNumber: String, startDate: String, endDate: String) -> Observable<T>
    func emailStatement<T: Codable>(url: String, month: String, year: String, statementType: String, cardType: String?) -> Observable<T>
}

class TransactionsService: BaseService, TransactionsServiceType {
   
    func fetchTransactions<T: Codable>(pageNumber: Int, pageSize: Int, minAmount: Double?, maxAmount: Double?, creditSearch: Bool?, debitSearch: Bool?, yapYoungTransfer: Bool?) -> Observable<T> {
        var params = [String: String]()

        if let minAmount = minAmount {
            params["amountStartRange"] = String(minAmount)
        }

        if let maxAmount = maxAmount {
            params["amountEndRange"] = String(maxAmount)
        }

        let creditSearch = creditSearch ?? false
        let debitSearch = debitSearch ?? false

        if creditSearch != debitSearch {
            params["txnType"] = creditSearch ? "CREDIT" : "DEBIT"
        }

        params["cardDetailsRequired"] = String(true)

        let route = APIEndpoint<String>(.get,
                                        apiConfig.transactionsURL,
                                        "/api/account-transactions/\(pageNumber)/\(pageSize)",
                                        pathVariables: nil,
                                        query: params,
                                        body: nil,
                                        headers: authorizationProvider.authorizationHeaders)
        
        return self.request(apiClient: apiClient, route: route)
    }

    func fetchCardTransactions<T: Codable>(cardSerialNumber: String, pageNumber: Int, pageSize: Int, debitSearch: Bool, filter: TransactionFilter?) -> Observable<T> {
        
        var query: [String: String] = [:]
        
        if let filter = filter {
            query = ["cardSerialNumber": cardSerialNumber, "cardDetailsRequired" : String(true), "debitSearch" : String(debitSearch), "amountStartRange": String(filter.minAmount), "amountEndRange" : String(filter.maxAmount), "ATM_WITHDRAW": String(filter.atmWidrawl), "POS" : String(filter.retail)]
        } else {
             query = ["cardSerialNumber": cardSerialNumber, "cardDetailsRequired" : String(true), "debitSearch" : String(debitSearch)]
        }
        
        
        
        let route = APIEndpoint<String>(.get,
                                        apiConfig.transactionsURL,
                                        "/api/cards-transactions/\(pageNumber)/\(pageSize)",
                                        pathVariables: nil,
                                        query: query,
                                        headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: apiClient, route: route)
    }

    func fetchReorderFee<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.transactionsURL, "/api/fees/reorder/debit-card/subscription/physical", pathVariables: nil, query: nil, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: apiClient, route: route)
    }
    
    func getTransactionFilters<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.transactionsURL, "/api/transactions/search-filter/amount", pathVariables: nil, query: nil, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: apiClient, route: route)
    }
    
    func Y2YTransfer<T: Codable>(receiverUUID: String, amount: String, beneficiaryName: String, note: String?, otpVerificationStatus: Bool) -> Observable<T> {
        
        let params : [String:String] = ["amount": amount, "receiverUUID": receiverUUID, "beneficiaryName": beneficiaryName, "deviceId": UIDevice.deviceID, "otpVerificationReq": String(otpVerificationStatus)] //, "isInternalUser":"true"]
        
        let route = APIEndpoint(.post, apiConfig.transactionsURL, "/api/y2y", body: params, headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: apiClient, route: route)
        
    }
    
    func getFee<T: Codable>(productCode: String) -> Observable<T> {
        let path = ["\(productCode)", "fees"]
        let route = APIEndpoint<String>(.post, apiConfig.transactionsURL, "/api/product-codes/", pathVariables: path,body: nil ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getTransactionProductLimit<T: Codable>(transactionProductCode: String) -> Observable<T> {
        let pathVariables = [transactionProductCode, "limits"]
        let route = APIEndpoint<String>(.get, apiConfig.transactionsURL, "/api/product/", pathVariables: pathVariables,body: nil ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getThresholdLimits<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.transactionsURL, "/api/transaction-thresholds", pathVariables: nil,body: nil ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getDenominationAmount<T: Codable>(productCode: String) -> Observable<T> {
        let pathVariables = [productCode, "denominations"]
        let route = APIEndpoint<String>(.get, apiConfig.transactionsURL, "/api/product/", pathVariables: pathVariables,body: nil ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func createCheckoutSession<T: Codable>(beneficiaryId: String, amount: String, currency: String, sessionId: String) -> Observable<T> {
        let body = PaymentGatewayRequest(order: PaymentGatewayAmountRequest(id: beneficiaryId.length > 0 ? beneficiaryId : nil, amount: amount, currency: currency), session: sessionId.length > 0 ? PaymentGatewaySessionRequest(id: sessionId) : nil)
        let route = APIEndpoint(.post, apiConfig.transactionsURL, "/api/mastercard/create-checkout-session", body: body ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func check3DSEnrollment<T: Codable>(orderId: String, beneficiaryID: Int, amount: String, currency: String, sessionID: String) -> Observable<T> {
        let body = PaymentGateway3DSEnrollmentRequest(beneficiaryID: beneficiaryID == 0 ? nil : beneficiaryID, order: PaymentGatewayAmountRequest(id: orderId, amount: amount, currency: currency), session: sessionID.count > 0 ? PaymentGatewaySessionRequest(id: sessionID) : nil)
        let route = APIEndpoint(.put, apiConfig.transactionsURL, "/api/mastercard/check-3ds-enrollment", body: body ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func retrieveACSResults<T: Codable>(threeDSecureID: String) -> Observable<T> {
        let pathVariables = [threeDSecureID]
        let route = APIEndpoint<String>(.get, apiConfig.transactionsURL, "/api/mastercard/retrieve-acs-results/3DSecureId/", pathVariables: pathVariables, body: nil ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func createCardHolder<T: Codable>(cardScheme: String, fee: String) -> Observable<T> {
        let body = PaymentCardTopupRequest(cardFee: fee, cardSchemeTitle: cardScheme)
        let route = APIEndpoint(.post, apiConfig.cardsURL, "/api/order-physical-card-of-cardholder", body: body ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func paymentGatewayFirstCreditTopup<T: Codable>(threeDSecureId: String, orderId: String, currency: String, amount: String, sessionId: String, securityCode: String, beneficiaryId: String) -> Observable<T> {
        let pathVariables = [orderId]
        let body = OrderCardRequest(threeDSecureId: threeDSecureId, order: PaymentGatewayAmountRequest(id: orderId, amount: amount, currency: currency), session: sessionId.length > 0 ? PaymentGatewaySessionRequest(id: sessionId) : nil, securityCode: securityCode, beneficiaryId: beneficiaryId.length > 0 ? beneficiaryId : nil)
        let route = APIEndpoint(.put, apiConfig.transactionsURL, "/api/mastercard/first-credit/order-id/", pathVariables: pathVariables, body: body, headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func paymentGatewayTopup<T: Codable>(threeDSecureId: String, orderId: String, currency: String, amount: String, sessionId: String, securityCode: String, beneficiaryId: String) -> Observable<T> {
        let pathVariables = [orderId]
        let body = OrderCardRequest(threeDSecureId: threeDSecureId, order: PaymentGatewayAmountRequest(id: orderId, amount: amount, currency: currency), session: sessionId.length > 0 ? PaymentGatewaySessionRequest(id: sessionId) : nil, securityCode: securityCode, beneficiaryId: beneficiaryId.length > 0 ? beneficiaryId : nil)
        let route = APIEndpoint(.put, apiConfig.transactionsURL, "/api/mastercard/order-id/", pathVariables: pathVariables, body: body, headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    
    public func fetchTransferReasons<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.transactionsURL, "/api/reasons-of-transfer", pathVariables: nil, query: nil, headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: apiClient, route: route)
    }
    
    public func sendMoneyViaBankTransfer<T: Codable>(input: SendMoneyBankTransferInput) -> Observable<T> {
        let route = APIEndpoint(.post, apiConfig.transactionsURL, "/api/bank-transfer", pathVariables: nil,body: input ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func cardStatement<T: Codable>(_ cardSerialNumber: String) -> Observable<T> {
        let query: [String: String] = ["cardSerialNumber": cardSerialNumber]
        let route = APIEndpoint<String>(.get, apiConfig.transactionsURL, "/api/card-statements", query: query, body: nil ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func cardCustomStatement<T: Codable>(_ cardSerialNumber: String, startDate: String, endDate: String) -> Observable<T> {
        let query: [String: String] = [
            "cardSerialNumber": cardSerialNumber,
            "fromDate": startDate,
            "toDate": endDate]
        let route = APIEndpoint<String>(.get, apiConfig.transactionsURL, "/api/card-statements", query: query, body: nil ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func emailStatement<T: Codable>(url: String, month: String, year: String, statementType: String, cardType: String?) -> Observable<T> {
//        let body = EmailStatementRequest(fileUrl: url, month: month, year: year, statementType: statementType, cardType: cardType)
//        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
//        let route = TransactionsRouter.emailStatement(input)
//        return request(apiClient: apiClient, route: route)
        
        let body = ["":""]
        
        let route = APIEndpoint(.post, apiConfig.transactionsURL, "/api/mastercard/create-checkout-session", body: body ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
}
