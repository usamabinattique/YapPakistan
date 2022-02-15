//
//  Y2YRepository.swift
//  YAPPakistan
//
//  Created by Umair  on 10/01/2022.
//

import Foundation
import RxSwift
import YAPComponents

public protocol Y2YRepositoryType: ContactsRepositoryType {
    func fetchRecentY2YBeneficiaries() -> Observable<Event<[Y2YRecentBeneficiary]>>
//    func fetchRecentBeneficiaries() -> Observable<Event<[Y2YRecentBeneficiary]>>
    func tranferFunds(uuid: String, name: String, amount: String, note: String?) -> Observable<Event<Y2YTransactionResponse>>
    func fee(productCode: String) -> Observable<Event<TransferFee>>
    func fetchCustomerAccountBalance() -> Observable<Event<CustomerBalanceResponse>>
//    func transactionThresholds() -> Observable<Event<TransactionThreshold>>
//    func fetchTransactionLimits(productCode: TransactionProductCode) -> Observable<Event<TransactionLimit>>
//    func getCoolingPeriod(accoundUUID: String) -> Observable<Event<BeneficiaryCoolingPeriod>>
//    func coolingPeriodTransactionReminder(for beneficiaryId: String, beneficiaryCreationDate: String?, beneficiaryName: String, amount: String ) -> Observable<Event<String?>>
    func getFee(productCode: String) -> Observable<Event<TransactionProductCodeFeeResponse>>
    func getTransactionProductLimit(transactionProductCode: String) -> Observable<Event<TransactionLimit>>
    func getThresholdLimits() -> Observable<Event<TransactionThreshold>>
    func Y2YTransfer(receiverUUID: String, amount: String, beneficiaryName: String, note: String?, otpVerificationStatus: Bool) -> Observable<Event<Y2YFundsTransferResponse>>
    func fetchPaymentGatewayBeneficiaries() -> Observable<Event<[ExternalPaymentCard]>>
}

public class Y2YRepository: Y2YRepositoryType {
    
    private let customersService: CustomersService
    private let transactionService: TransactionsService

    init(customersService: CustomersService, transactionService: TransactionsService) {
        self.customersService = customersService
        self.transactionService = transactionService
    }
    
    public func classifyContacts(_ contacts: [Contact])-> Observable<Event<[YAPContact]>> {
//        return Observable.of(YAPContact.mock).materialize()
        return customersService.classifyContacts(contacts: contacts.map { (name: $0.name, phoneNumber: $0.phoneNumber, email: $0.email, photoUrl: $0.photoUrl, countryCode: $0.countryCode )}).materialize()
    }
    
    public func fetchRecentY2YBeneficiaries() -> Observable<Event<[Y2YRecentBeneficiary]>> {
//        return Observable.of([Y2YRecentBeneficiary.mock]).materialize()
        return customersService.fetchRecentY2YBeneficiaries().materialize()
    }
//
//    public func fetchRecentBeneficiaries() -> Observable<Event<[Y2YRecentBeneficiary]>> {
//        return customersService.fetchRecentBeneficiaries().materialize()
//    }
//
    public func tranferFunds(uuid: String, name: String, amount: String, note: String?) -> Observable<Event<Y2YTransactionResponse>> {
        return transactionService.Y2YTransfer(receiverUUID: uuid, amount: amount, beneficiaryName: name, note: note, otpVerificationStatus: false).materialize()
    }
//
    public func fee(productCode: String) -> Observable<Event<TransferFee>> {
        transactionService.getFee(productCode: productCode).materialize()
    }
    
    public func fetchCustomerAccountBalance() -> Observable<Event<CustomerBalanceResponse>> {
        return customersService.fetchCustomerAccountBalance().materialize()
    }
//
//    public func transactionThresholds() -> Observable<Event<TransactionThreshold>> {
//        transactionService.transactionsThresholds().materialize()
//    }
//
//    public func fetchTransactionLimits(productCode: TransactionProductCode) -> Observable<Event<TransactionLimit>> {
//        return transactionService.fetchTransactionLimit(productCode.rawValue).materialize()
//    }
//
//    public func getCoolingPeriod(accoundUUID: String) -> Observable<Event<BeneficiaryCoolingPeriod>> {
//        return customersService.getCoolingPeriod(for: accoundUUID, productCode: TransactionProductCode.y2yTransfer.rawValue).materialize()
//    }
//
//    public func coolingPeriodTransactionReminder(for beneficiaryId: String, beneficiaryCreationDate: String?, beneficiaryName: String, amount: String) -> Observable<Event<String?>> {
//        transactionService.coolingPeriodTransactionReminder(beneficiaryId: beneficiaryId, beneficiaryCreationDate: beneficiaryCreationDate, beneficiaryName: beneficiaryName, amount: amount).materialize()
//    }
    
    public func getFee(productCode: String) -> Observable<Event<TransactionProductCodeFeeResponse>> {
        return transactionService.getFee(productCode: productCode).materialize()
    }
    
    public func getTransactionProductLimit(transactionProductCode: String) -> Observable<Event<TransactionLimit>> {
        transactionService.getTransactionProductLimit(transactionProductCode: transactionProductCode).materialize()
    }
    
    public func getThresholdLimits() -> Observable<Event<TransactionThreshold>> {
        return transactionService.getThresholdLimits().materialize()
    }
    
    public func Y2YTransfer(receiverUUID: String, amount: String, beneficiaryName: String, note: String?, otpVerificationStatus: Bool) -> Observable<Event<Y2YFundsTransferResponse>> {
        return transactionService.Y2YTransfer(receiverUUID: receiverUUID, amount: amount, beneficiaryName: beneficiaryName, note: note, otpVerificationStatus: otpVerificationStatus).materialize()
    }
    
    public func fetchPaymentGatewayBeneficiaries() -> Observable<Event<[ExternalPaymentCard]>> {
        customersService.fetchPaymentGatewayBeneficiaries().materialize()
    }
}

public class MockY2YRepository: Y2YRepositoryType {
    public func fetchPaymentGatewayBeneficiaries() -> Observable<Event<[ExternalPaymentCard]>> {
        Observable.create { observer in
            observer.onNext([.mock])
            return Disposables.create()
        }.materialize()
    }
    
    public func getFee(productCode: String) -> Observable<Event<TransactionProductCodeFeeResponse>> {
        Observable.create { observer in
            observer.onNext(.mock)
            return Disposables.create()
        }.materialize()
    }
    
    public func getTransactionProductLimit(transactionProductCode: String) -> Observable<Event<TransactionLimit>> {
        Observable.create { observer in
            observer.onNext(.mock)
            return Disposables.create()
        }.materialize()
    }
    
    public func getThresholdLimits() -> Observable<Event<TransactionThreshold>> {
        Observable.create { observer in
            observer.onNext(.mock)
            return Disposables.create()
        }.materialize()
    }
    
    public func Y2YTransfer(receiverUUID: String, amount: String, beneficiaryName: String, note: String?, otpVerificationStatus: Bool) -> Observable<Event<Y2YFundsTransferResponse>> {
        Observable.create { observer in
            observer.onNext(.mock)
            return Disposables.create()
        }.materialize()
    }
    
    public func fetchCustomerAccountBalance() -> Observable<Event<CustomerBalanceResponse>> {
        Observable.create { observer in
            observer.onNext(.mock)
            return Disposables.create()
        }.materialize()
    }
    
    public func fee(productCode: String) -> Observable<Event<TransferFee>> {
        Observable.create { observer in
            observer.onNext(.mock)
            return Disposables.create()
        }.materialize()
    }
    
//    public func coolingPeriodTransactionReminder(for beneficiaryId: String, beneficiaryCreationDate: String?, beneficiaryName: String, amount: String) -> Observable<Event<String?>> {
//        Observable.create { observer in
//            observer.onNext(nil)
//            return Disposables.create()
//        }.materialize()
//    }

    public func classifyContacts(_ contacts: [Contact]) -> Observable<Event<[YAPContact]>> {
        return Observable.of(YAPContact.mock).materialize()
//        Observable.create { observer in
//            observer.onNext([YAPContact.init(name: "John Doe", phoneNumber: "+15417543010", countryCode: "+1", email: nil, isYapUser: true, photoUrl: nil, yapAccountDetails: nil, thumbnailData: nil, index: nil)])
//            return Disposables.create()
//        }.materialize()
    }

    public func fetchRecentY2YBeneficiaries() -> Observable<Event<[Y2YRecentBeneficiary]>> {
        Observable.create { observer in
            observer.onNext([.mock])
            return Disposables.create()
        }.materialize()
    }

    public func tranferFunds(uuid: String, name: String, amount: String, note: String?) -> Observable<Event<Y2YTransactionResponse>> {
        Observable.create { observer in
            observer.onNext(Y2YTransactionResponse.init(transactionId: "", balance: "2252", currency: "AED"))
            return Disposables.create()
        }.materialize()
    }
//
//    public func fee(productCode: String) -> Observable<Event<TransferFee>> {
//        Observable.create { observer in
//            observer.onNext(TransferFee.mock)
//            return Disposables.create()
//        }.materialize()
//    }
//
//    public func transactionThresholds() -> Observable<Event<TransactionThreshold>> {
//        Observable.create { observer in
//            observer.onNext(.mock)
//            return Disposables.create()
//        }.materialize()
//    }
//
//    public func fetchTransactionLimits(productCode: TransactionProductCode) -> Observable<Event<TransactionLimit>> {
//        Observable.create { observer in
//            observer.onNext(.mock)
//            return Disposables.create()
//        }.materialize()
//    }
//
//    public func getCoolingPeriod(accoundUUID: String) -> Observable<Event<BeneficiaryCoolingPeriod>> {
//        Observable.create { observer in
//            observer.onNext(.mock)
//            return Disposables.create()
//        }.materialize()
//    }
}
