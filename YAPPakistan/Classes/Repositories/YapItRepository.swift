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
    
//    func fetchBeneficiaryCountries() -> Observable<Event<[SendMoneyBeneficiaryCountry]>>
}

class YapItRepository: YapItRepositoryType {
    
    private let customersService: CustomersService

    init(customersService: CustomersService) {
        self.customersService = customersService
    }
    
    public func fetchRecentSendMoneyBeneficiaries() -> Observable<Event<[SendMoneyBeneficiary]>> {
        return customersService.fetchRecentBeneficiaries().materialize()
    }
    
    public func fetchRecentY2YBeneficiaries() -> Observable<Event<[Y2YRecentBeneficiary]>> {
        return Observable.of([Y2YRecentBeneficiary.mock]).materialize()
//        return customersService.fetchRecentBeneficiaries().materialize()
    }
    
//    func fetchBeneficiaryCountries() -> Observable<Event<[SendMoneyBeneficiaryCountry]>> {
//        return self.customersService.fetchBeneficiaryCountries().materialize()
//    }
}
