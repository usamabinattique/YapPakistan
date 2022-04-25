//
//  AccountRepository.swift
//  YAPKit
//
//  Created by Hussaan S on 31/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

public protocol AccountRepositoryType {
    func fetchAccounts() -> Observable<Event<[Account]>>
    func assignIBAN(countryCode: String, mobileNo: String) -> Observable<Event<String?>>
    func fetchCustomerPersonalDetails() -> Observable<Event<Customer?>>
    func logout(deviceUUID: String) -> Observable<Event<[String: String]?>>
}

public class AccountRepository: AccountRepositoryType {
    private let authenticationService: AuthenticationServiceType
    private let customerService: CustomersService

    public init(authenticationService: AuthenticationServiceType,
                customerService: CustomersService) {
        self.authenticationService = authenticationService
        self.customerService = customerService
    }

    public func fetchCustomerPersonalDetails() -> Observable<Event<Customer?>> {
        return customerService.fetchCustomerPersonalDetails().materialize()
    }
    
    public func fetchAccounts() -> Observable<Event<[Account]>> {
        return customerService.fetchAccounts().materialize()
    }

    public func assignIBAN(countryCode: String, mobileNo: String) -> Observable<Event<String?>> {
        return customerService.assignIBAN(countryCode: countryCode, mobileNo: mobileNo).materialize()
    }

    public func logout(deviceUUID: String) -> Observable<Event<[String: String]?>> {
        return authenticationService.logout(deviceUUID: deviceUUID).materialize()
    }
}
