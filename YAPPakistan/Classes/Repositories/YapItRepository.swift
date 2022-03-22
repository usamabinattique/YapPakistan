//
//  YapItRepository.swift
//  YAPPakistan
//
//  Created by Umair  on 04/01/2022.
//

import Foundation
import RxSwift

protocol YapItRepositoryType {
    func fetchRecentSendMoneyBeneficiaries() -> Observable<Event<[SendMoneyBeneficiary]>>
    
    func fetchRecentY2YBeneficiaries() -> Observable<Event<[Y2YRecentBeneficiary]>>
    func getCustomerInfoFromQR(_ qrString: String) -> Observable<Event<QRContact>>
    func getBankDetail() -> Observable<Event<[BankDetail]>>
    func getBeneficiaryAccountTitle(accountNo: String, consumerId: String) -> Observable<Event<BankAccountDetail>>
//    func fetchBeneficiaryCountries() -> Observable<Event<[SendMoneyBeneficiaryCountry]>>
}

class YapItRepository: YapItRepositoryType {
    
    private let customersService: CustomersService

    init(customersService: CustomersService) {
        self.customersService = customersService
    }
    
    public func fetchRecentSendMoneyBeneficiaries() -> Observable<Event<[SendMoneyBeneficiary]>> {
        return customersService.fetchRecentSendMoneyBeneficiaries().materialize()
    }
    
    public func fetchRecentY2YBeneficiaries() -> Observable<Event<[Y2YRecentBeneficiary]>> {
//        return Observable.of([Y2YRecentBeneficiary.mock]).materialize()
        return customersService.fetchRecentBeneficiaries().materialize()
    }
    
    public func getCustomerInfoFromQR(_ qrString: String) -> Observable<Event<QRContact>> {
        return customersService.getCustomerInfoFromQR(qrString).materialize()
    }
    
    public func getBankDetail() -> Observable<Event<[BankDetail]>>{
        return customersService.getBankDetail().materialize()
    }
    
    public func getBeneficiaryAccountTitle(accountNo: String, consumerId: String) -> Observable<Event<BankAccountDetail>> {
        return customersService.fetchBeneficiaryAccountTitle(accountNo: accountNo, consumerId: consumerId).materialize()
    }
    
    
//    func fetchBeneficiaryCountries() -> Observable<Event<[SendMoneyBeneficiaryCountry]>> {
//        return self.customersService.fetchBeneficiaryCountries().materialize()
//    }
    
    
}
