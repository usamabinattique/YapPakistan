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
    func createCheckoutSession<T: Codable>(amount: String, currency: String, sessionId: String) -> Observable<T>
    func check3DSEnrollment<T: Codable>(beneficiaryID: Int, amount: String, currency: String, sessionID: String) -> Observable<T>
    func retrieveACSResults<T: Codable>(threeDSecureID: String) -> Observable<T>
    func paymentGatewayTopup<T: Codable>(orderID: String, beneficiaryID: Int, amount: String, currency: String, securityCode: String, threeDSecureID: String) -> Observable<T>
    
    
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
                                        "/api/account-transactions",
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
        
     //   let request = Y2YTransferRequest(receiverUUID: receiverUUID, amount: amount, remarks: note?.isEmpty ?? true ? nil : note, beneficiaryName: beneficiaryName, otpVerificationReq: otpVerificationStatus, deviceId: UIDevice.deviceID)
//        let input: RouterInput = (body: request, query: nil, pathVariables: nil)
//        let route = TransactionsRouter.Y2YTransfer(input)
        
        let params : [String:String] = ["amount": amount, "receiverUUID": receiverUUID, "beneficiaryName": beneficiaryName, "deviceId": UIDevice.deviceID, "otpVerificationReq": String(otpVerificationStatus)] //, "isInternalUser":"true"]
        
        let route = APIEndpoint(.post, apiConfig.transactionsURL, "/api/y2y", body: params, headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: apiClient, route: route)
        
    }
    
    func getFee<T: Codable>(productCode: String) -> Observable<T> {
        let path = ["\(productCode)", "fees"]
//        let input: RouterInput<Int> = RouterInput(body: nil, query: nil, pathVariables: path)
//        let route = TransactionsRouter.getFee(input)
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
    
    public func createCheckoutSession<T: Codable>(amount: String, currency: String, sessionId: String) -> Observable<T> {
        let body = PaymentGatewayRequest(order: PaymentGatewayAmountRequest(amount: amount, currency: currency), session: PaymentGatewaySessionRequest(id: "SESSION0002255503807J8363138J24"))
        let route = APIEndpoint(.post, apiConfig.transactionsURL, "/api/mastercard/create-checkout-session", body: body ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func check3DSEnrollment<T: Codable>(beneficiaryID: Int, amount: String, currency: String, sessionID: String) -> Observable<T> {
        let body = PaymentGateway3DSEnrollmentRequest(beneficiaryID: beneficiaryID, order: PaymentGatewayAmountRequest(amount: amount, currency: currency), session: PaymentGatewaySessionRequest(id: sessionID))
        let route = APIEndpoint(.put, apiConfig.transactionsURL, "/api/mastercard/check-3ds-enrollment", body: body ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func retrieveACSResults<T: Codable>(threeDSecureID: String) -> Observable<T> {
        let pathVariables = [threeDSecureID]
        let route = APIEndpoint<String>(.get, apiConfig.transactionsURL, "/api/mastercard/retrieve-acs-results/", pathVariables: pathVariables, body: nil ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func paymentGatewayTopup<T: Codable>(orderID: String, beneficiaryID: Int, amount: String, currency: String, securityCode: String, threeDSecureID: String) -> Observable<T> {
        let pathVariables = [orderID]
        let body = PaymentCardTopupRequest(beneficiaryID: beneficiaryID, order: PaymentGatewayAmountRequest(amount: amount, currency: currency), securityCode: securityCode, threeDSecureId: threeDSecureID)
        let route = APIEndpoint(.get, apiConfig.cardsURL, "/api/order-physical-card-of-cardholder", pathVariables: pathVariables, body: body ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
}


/*
 class TransactionsService: BaseService {
    
    func Y2YTransfer<T: Codable>(receiverUUID: String, amount: String, beneficiaryName: String, note: String?, otpVerificationStatus: Bool) -> Observable<T> {
        
        let request = Y2YTransferRequest(receiverUUID: receiverUUID, amount: amount, remarks: note?.isEmpty ?? true ? nil : note, beneficiaryName: beneficiaryName, otpVerificationReq: otpVerificationStatus)
        let input: RouterInput = (body: request, query: nil, pathVariables: nil)
        let route = TransactionsRouter.Y2YTransfer(input)
        return self.request(apiClient: apiClient, route: route)
        
    }
    
    func fetchTransactionDetails<T: Codable>(transactionId: String) -> Observable<T> {
        let input: RouterInput<String> = RouterInput(body: nil, query: nil, pathVariables: ["\(transactionId)"])
        let route = TransactionsRouter.transactionDetail(input)
        return self.request(apiClient: apiClient, route: route)
    }
    
    func addNote<T: Codable>(transactionId: String, senderTransactionNote: String?, receiverTransactionNote: String?) -> Observable<T> {
        
        //        var request = AddNoteRequest(transactionId: transactionId, transactionNote: nil, receiverTransactionNote: nil)
        
        let request = AddNoteRequest(transactionId: transactionId, transactionNote: senderTransactionNote, receiverTransactionNote: receiverTransactionNote)
        let input: RouterInput = (body: request, query: nil, pathVariables: nil)
        let route = TransactionsRouter.addNote(input)
        return self.request(apiClient: self.apiClient, route: route)
        
        //        if let senderTransactionNote = senderTransactionNote {
        //            let request = AddNoteRequest(transactionId: transactionId, transactionNote: senderTransactionNote, receiverTransactionNote: nil)
        //            let input: RouterInput = (body: request, query: nil, pathVariables: nil)
        //            let route = TransactionsRouter.addNote(input)
        //            return self.request(apiClient: self.apiClient, route: route)
        //        }
        //
        //        if let receiverTransactionNote = receiverTransactionNote {
        //            let request = AddNoteRequest(transactionId: transactionId, transactionNote: nil, receiverTransactionNote: receiverTransactionNote)
        //            let input: RouterInput = (body: request, query: nil, pathVariables: nil)
        //            let route = TransactionsRouter.addNote(input)
        //            return self.request(apiClient: self.apiClient, route: route)
        //        }
        //
        //        return Observable.never()
        
    }
    
    func getMonths<T: Codable>(cardSerialNumber: String) -> Observable<T> {
        let query = ["cardSerialNo": cardSerialNumber]
        let input: RouterInput<Int> = RouterInput(body: nil, query: query, pathVariables: nil)
        let route = TransactionsRouter.months(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getTransactionsByMerchant<T: Codable>(cardSerialNumber: String, date: String) -> Observable<T> {
        
       // let query = ["cardSerialNo": cardSerialNumber, "date": date]
        let query = ["date": date]
        let input: RouterInput<Int> = RouterInput(body: nil, query: query, pathVariables: nil)
        let route = TransactionsRouter.transactionsByMerchantName(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getTransactionsByCategory<T: Codable>(cardSerialNumber: String, date: String) -> Observable<T> {
        
        //let query = ["cardSerialNo": cardSerialNumber, "date": date]
        let query = ["date": date]
        let input: RouterInput<Int> = RouterInput(body: nil, query: query, pathVariables: nil)
        let route = TransactionsRouter.transactionsByCategory(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getDenominationAmount<T: Codable>(productCode: String) -> Observable<T> {
        let pathVariables = [productCode, "denominations"]
        let input: RouterInput<String> = RouterInput(body: nil, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.denominationAmount(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getQuickTopUpAmounts<T: Codable>() -> Observable<T> {
        let input: RouterInput<String> = RouterInput(body: nil, query: nil, pathVariables: nil)
        let route = TransactionsRouter.denominationAmount(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getDebitCardTopUpLimits<T: Codable>() -> Observable<T> {
        let input: RouterInput<String> = RouterInput(body: nil, query: nil, pathVariables: nil)
        let route = TransactionsRouter.debitCardTopUpLimits(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func performDebitCardTopUp<T: Codable>(_ amount: String, from cardPAN: String) -> Observable<T> {
        let request = TopUpDebitCardRequest(amount: amount, fromCardPAN: cardPAN, channel: "iOS", remarks: "Beta Testing")
        let input: RouterInput = RouterInput(body: request, query: nil, pathVariables: nil)
        let route = TransactionsRouter.debitCardTopUp(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getTransactions<T: Codable>(_ uuid: String) -> Observable<T> {
        
        let body = TransactionsHistoryRequest(uuid: uuid)
        let input: RouterInput = (body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.transactionsHistory(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getProductLimit<T: Codable>() -> Observable<T> {
        let input: RouterInput<String> = RouterInput(body: nil, query: nil, pathVariables: nil)
        let route = TransactionsRouter.topUpProductLimit(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getWithdrawProductLimits<T: Codable>() -> Observable<T> {
        let input: RouterInput<String> = RouterInput(body: nil, query: nil, pathVariables: nil)
        let route = TransactionsRouter.withdrawProductLimit(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func performSubCardTopUp<T: Codable>(_ amount: String, toCard cardSerialNumber: String) -> Observable<T> {
        let request = TopUpSubCardRequest(amount: amount, toCard: cardSerialNumber)
        let input: RouterInput = RouterInput(body: request, query: nil, pathVariables: nil)
        let route = TransactionsRouter.subCardTopUp(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func fetchTransferReasons<T: Codable>(_ productCode: String) -> Observable<T> {
        let pathVariables = [productCode]
        let input: RouterInput<Int> = RouterInput(body: nil, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.productReasons(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func fetchTransferFee<T: Codable>(_ productCode: String, destinationCountry: String, sourceCurrency: String, destinationCurrency: String, conversionCurrency: String, amount: String) -> Observable<T> {
        let pathVariables = [productCode, "fees"]
        let request = SendMoneyTransferFeeRequest(destinationCountry: destinationCountry, amount: SendMoneyTransferFeeAmountRequest(destinationCurrency: conversionCurrency, amount: amount), sourceCurrency: sourceCurrency, destinationCurrency: destinationCurrency)
        let input: RouterInput = RouterInput(body: request, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.productFee(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func fetchTransactionLimit<T: Codable>(_ productCode: String) -> Observable<T> {
        let pathVariables = [productCode, "limits"]
        let input: RouterInput<Int> = RouterInput(body: nil, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.transactionLimit(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func performSubCardWithdraw<T: Codable>(_ amount: String, fromCard cardSerialNumber: String) -> Observable<T> {
        let request = WithdrawSubCardRequest(amount: amount, fromCard: cardSerialNumber)
        let input: RouterInput = RouterInput(body: request, query: nil, pathVariables: nil)
        let route = TransactionsRouter.subCardWithdraw(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func cardStatement<T: Codable>(_ cardSerialNumber: String) -> Observable<T> {
        let query = ["cardSerialNumber": cardSerialNumber]
        let input: RouterInput<Int> = RouterInput(body: nil, query: query, pathVariables: nil)
        let route = TransactionsRouter.cardStatement(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func domestic<T: Codable>(_ beneficiaryID: Int, amount: String, purposeCode: String, purposeReason: String, remarks: String?) -> Observable<T> {
        
        let body = SendMoneyFundsTransferRequest(domestic: beneficiaryID, amount: amount, purposeCode: purposeCode, purposeReason: purposeReason, remarks: remarks)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.domestic(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func uaefts<T: Codable>(_ beneficiaryID: Int, amount: String, purposeCode: String, purposeReason: String, remarks: String?, nonChargeable: Bool?, cbwsi: Bool?, cbwsiFee: Bool?, fee: Double, vat: Double) -> Observable<T> {
        
        let body = SendMoneyFundsTransferRequest(uaefts: beneficiaryID, amount: amount, purposeCode: purposeCode, purposeReason: purposeReason, remarks: remarks, nonChargeable: nonChargeable, cbwsi: cbwsi, cbwsiFee: cbwsiFee, feeAmount: fee, vat: vat)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.uaefts(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func rmt<T: Codable>(_ beneficiaryID: Int, sourceAmount: String, destinationAmount: String, purposeCode: String, purposeReason: String, remarks: String?, currency: String, fxRate: String) -> Observable<T> {
        
        let body = SendMoneyFundsTransferRequest(rmt: beneficiaryID, sourceAmount: sourceAmount, destinationAmount: destinationAmount, purposeCode: purposeCode, purposeReason: purposeReason, remarks: remarks, currency: currency, fxRate: fxRate)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.rmt(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func swift<T: Codable>(_ beneficiaryID: Int, sourceAmount: String, destinationAmount: String, purposeCode: String, purposeReason: String, remarks: String?, currency: String, fxRate: String) -> Observable<T> {
        
        let body = SendMoneyFundsTransferRequest(swift: beneficiaryID, sourceAmount: sourceAmount, destinationAmount: destinationAmount, purposeCode: purposeCode, purposeReason: purposeReason, remarks: remarks, currency: currency, fxRate: fxRate)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.swift(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func cashPayout<T: Codable>(_ beneficiaryID: Int, amount: String, purposeCode: String?, purposeReason: String?, remarks: String?, currency: String?) -> Observable<T> {
        
        let body = SendMoneyFundsTransferRequest(cashpayout: beneficiaryID, amount: amount, purposeCode: purposeCode, purposeReason: purposeReason, remarks: remarks, currency: currency)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.cashPayout(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getSpareCardFee<T: Codable>(_ cardType: String) -> Observable<T> {
        let pathVariables = [cardType]
        let input: RouterInput<Int> = RouterInput(body: nil, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.getSpareCardFee(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getDebitCardFee<T: Codable>() -> Observable<T> {
        let input: RouterInput<Int> = RouterInput(body: nil, query: nil, pathVariables: nil)
        let route = TransactionsRouter.getDebitCardFee(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getFee<T: Codable>(productCode: String) -> Observable<T> {
        let path = ["\(productCode)", "fees"]
        let input: RouterInput<Int> = RouterInput(body: nil, query: nil, pathVariables: path)
        let route = TransactionsRouter.getFee(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getTransactionFilters<T: Codable>() -> Observable<T> {
        let input: RouterInput<Int> = RouterInput(body: nil, query: nil, pathVariables: nil)
        let route = TransactionsRouter.fetchSearchLimit(input)
        return self.request(apiClient: apiClient, route: route)
    }
    
    func createCheckoutSession<T: Codable>(amount: String, currency: String) -> Observable<T> {
        let body = ["order": PaymentGatewayAmountRequest(amount: amount, currency: currency)]
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.createCheckoutSession(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func check3DSEnrollment<T: Codable>(beneficiaryID: Int, amount: String, currency: String, sessionID: String) -> Observable<T> {
        let body = PaymentGateway3DSEnrollmentRequest(beneficiaryID: beneficiaryID, order: PaymentGatewayAmountRequest(amount: amount, currency: currency), session: PaymentGatewaySessionRequest(id: sessionID))
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.check3DSEnrollment(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func retrieveACSResults<T: Codable>(threeDSecureID: String) -> Observable<T> {
        let pathVariables = [threeDSecureID]
        let input: RouterInput<Int> = RouterInput(body: nil, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.retrieveACSResults(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func paymentGatewayTopup<T: Codable>(orderID: String, beneficiaryID: Int, amount: String, currency: String, securityCode: String, threeDSecureID: String) -> Observable<T> {
        let pathVariables = [orderID]
        let body = PaymentCardTopupRequest(beneficiaryID: beneficiaryID, order: PaymentGatewayAmountRequest(amount: amount, currency: currency), securityCode: securityCode, threeDSecureId: threeDSecureID)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.paymentGatewayTopup(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getTransactionProductLimit<T: Codable>(transactionProductCode: String) -> Observable<T> {
        let pathVariables = [transactionProductCode, "limits"]
        let input: RouterInput<String> = RouterInput(body: nil, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.topupViaCardProductLimit(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getFxRate<T: Codable>(productCode: String, beneficiaryId: String) -> Observable<T> {
        let pathVariables = [productCode, "fxRate"]
        let body = FxRateRequest(beneficiaryId: beneficiaryId)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.productFee(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func transferFeeForCountry<T: Codable>(productCode: String, country: String, currency: String?) -> Observable<T> {
        let pathVariables = [productCode, "fees"]
        let body = TranfserFeeForCountryReqeust(country: country, currency: currency)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.productFee(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getHouseholdMonthlySubcriptionFee<T: Codable>() -> Observable<T> {
        let pathVariables = ["Monthly"]
        let input: RouterInput<String> = RouterInput(body: nil, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.getHouseholdPackageFee(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getHouseholdYearlySubcriptionFee<T: Codable>() -> Observable<T> {
        let pathVariables = ["Annual"]
        let input: RouterInput<String> = RouterInput(body: nil, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.getHouseholdPackageFee(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func transactionsThresholds<T: Codable>() -> Observable<T> {
        let input: RouterInput<Int> = RouterInput(body: nil, query: nil, pathVariables: nil)
        let route = TransactionsRouter.transactionThresholds(input)
        return self.request(apiClient: apiClient, route: route)
    }
    
    func getCutOffTime<T: Codable>(productCode: String, currencyCode: String, amount: String, isCbwsi: String) -> Observable<T> {
        let query = ["productCode" : productCode, "currency" : currencyCode, "amount" : amount, "isCbwsi": isCbwsi]
        let input: RouterInput<Int> = RouterInput(body: nil, query: query, pathVariables: nil)
        let route = TransactionsRouter.getCutOffTime(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func fetchAchievemets<T: Codable>() -> Observable<T> {
        let input: RouterInput<String> = RouterInput(body: nil, query: nil, pathVariables: nil)
        let route = TransactionsRouter.fetchAchievements(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func accountStatements<T: Codable>() -> Observable<T> {
        let input: RouterInput<Int> = RouterInput(body: nil, query: nil, pathVariables: nil)
        let route = TransactionsRouter.accountStatements(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func sendHouseholdPayment<T: Codable>(to uuid: String, amount: String, remarks: String, beneficiaryName: String) -> Observable<T> {
        let body = HouseHoldSendPayment(receiverUUID: uuid, amount: amount, remarks: remarks, beneficiaryName: beneficiaryName)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.sendHouseHoldPayment(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func sendHouseholdMoney<T: Codable>(to: String, amount: String, remarks: String, beneficiaryName: String, txnCategory: String, txnSubCategory: String) -> Observable<T> {
        let body = HouseHoldSendMoney(receiverUUID: to, amount: amount, remarks: remarks, beneficiaryName: beneficiaryName, txnCategory: txnCategory, txnSubCategory: txnSubCategory)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.sendHouseHoldMoney(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func coolingPeriodTransactionReminder<T: Codable>(beneficiaryId: String, beneficiaryCreationDate: String?, beneficiaryName: String, amount: String) -> Observable<T> {
        var query = ["beneficiaryId" : beneficiaryId, "beneficiaryName" : beneficiaryName, "amount": amount]
        if let creationDate = beneficiaryCreationDate { query["beneficiaryCreationDate"] = creationDate }
        let input: RouterInput<Int> = RouterInput(body: nil, query: query, pathVariables: nil)
        let route = TransactionsRouter.coolingPeriodTransactionReminder(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func testFunc<T: Codable>(to: String, amount: String, remarks: String, beneficiaryName: String, txnCategory: String, txnSubCategory: String) -> Observable<T> {
        let body = HouseHoldSendMoney(receiverUUID: to, amount: amount, remarks: remarks, beneficiaryName: beneficiaryName, txnCategory: txnCategory, txnSubCategory: txnSubCategory)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.sendHouseHoldMoney(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func fetchMerchantAnalytics<T: Codable>(cardSerialNo: String, date: String, categories: [String]?) -> Observable<T> {
        let query = ["cardSerialNo" : cardSerialNo, "date" : date]
        let input: RouterInput = RouterInput(body: categories, query: query, pathVariables: nil)
        let route = TransactionsRouter.fetchMerchantAnalytics(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func fetchCategoryAnalytics<T: Codable>(cardSerialNo: String, date: String, categories: [Int?]) -> Observable<T> {
        let query = ["cardSerialNo" : cardSerialNo, "date" : date]
        let input: RouterInput = RouterInput(body: categories, query: query, pathVariables: nil)
        let route = TransactionsRouter.fetchCategoryAnalytics(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getFxRate<T: Codable>(for country: String) -> Observable<T> {
        let body = ["other_bank_country": country]
        let input: RouterInput<[String: String]> = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.getFxRate(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getLatesTransactionState<T: Codable>() -> Observable<T> {
        let pathVariable = ["transaction-states"]
        let input: RouterInput<Int> = RouterInput(body: nil, query: nil, pathVariables: pathVariable)
        let route = TransactionsRouter.latestTransactionState(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func uploadReceiptPhoto<T: Codable>(transactionId: String, data: Data, name: String, fileName: String, mimeType: String, progressObserver: AnyObserver<Progress>?) -> Observable<T> {
        let addReceiptPhotoRequest = DocumentUploadRequest(data: data, name: name, fileName: fileName, mimeType: mimeType)
        let documents = [addReceiptPhotoRequest]
        let profilePhotoRequest = AddReceiptPhotoRequest.init(receiptPhoto: addReceiptPhotoRequest.data)
        let query = ["transaction-id" : transactionId]
        let input = RouterInput(body: profilePhotoRequest, query: query, pathVariables: nil)
        let route = TransactionsRouter.uploadReceiptPhoto(input)
        return self.upload(apiClient: apiClient, documents: documents, route: route, progressObserver: progressObserver, otherFormValues: [:])
    }
    
    func getAllReceipts<T: Codable>(_ transactionId: String) -> Observable<T> {
        let pathVariables = [transactionId]
        let input: RouterInput<String> = RouterInput(body: nil, query: nil, pathVariables: pathVariables)
        let route = TransactionsRouter.gatAllReceipts(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func deleteReceipts<T: Codable>(_ transactionId: String, imageName: String) -> Observable<T> {
        let query = ["transaction-id" : transactionId, "receipt-image": imageName]
        let input: RouterInput<String> = RouterInput(body: nil, query: query, pathVariables: nil)
        let route = TransactionsRouter.deleteReceipts(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func fetchTotalPurchaseData<T: Codable>( transactionType: String, beneficiaryId: String?, receiverCustomerId: String?, productCode: String, merchantName: String?, senderCustomerId: String?) -> Observable<T> {
        
        var query = [String: String]()

        query = ["txnType" : transactionType, "productCode": productCode]
        
        if let beneficiaryId = beneficiaryId {
            query["beneficiaryId"] = String(beneficiaryId)
        }
        
        if let senderCustomerId = senderCustomerId {
            query["senderCustomerId"] = String(senderCustomerId)
        }
        
        if let receiverCustomerId = receiverCustomerId {
            query["receiverCustomerId"] = String(receiverCustomerId)
        }
        
        if let merchantName = merchantName {
            query["merchantName"] = String(merchantName)
        }
        
        let input: RouterInput<String> = RouterInput(body: nil, query: query, pathVariables: nil)
        let route = TransactionsRouter.totalPurchase(input)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    func getAllTransactionCategories<T: Codable>() -> Observable<T> {
        let input: RouterInput<Int?> = RouterInput(body: nil, query: nil, pathVariables: nil)
        let route = TransactionsRouter.getAllTransactionCategories(input)
        return request(apiClient: apiClient, route: route)
    }
    
    func updateTransactionCategory<T: Codable>(transactionId: String, categoryId: String) -> Observable<T> {
        let queryParams = ["transaction-id": transactionId, "category-id": categoryId]
        let input: RouterInput<String> = RouterInput(body: nil, query: queryParams, pathVariables: nil)
        let route = TransactionsRouter.updateTransactionCategory(input)
        return request(apiClient: apiClient, route: route)
    }
    
    func emailStatement<T: Codable>(url: String, month: String, year: String, statementType: String) -> Observable<T> {
        let body = EmailStatementRequest(fileUrl: url, month: month, year: year, statementType: statementType)
        let input: RouterInput = RouterInput(body: body, query: nil, pathVariables: nil)
        let route = TransactionsRouter.emailStatement(input)
        return request(apiClient: apiClient, route: route)
    }
}
*/
