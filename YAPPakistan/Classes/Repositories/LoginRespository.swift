//
//  LoginRepository.swift
//  YAP
//
//  Created by Wajahat Hassan on 02/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

public class LoginRepository {
    
    private let customerService: CustomersService
    private let authenticationService: AuthenticationServiceType
    private let messageService: MessagesService
    
    public init(customerService: CustomersService,
         authenticationService: AuthenticationServiceType,
         messageService: MessagesService) {
        self.customerService = customerService
        self.authenticationService = authenticationService
        self.messageService = messageService
    }
    
    let disposeBag = DisposeBag()
    
    public func verifyUser(username: String) -> Observable<Event<Bool>> {
        return customerService.verifyUser(username: username).materialize()
    }
    
    public func verifyPasscode(passcode: String) -> Observable<Event<String?>> {
        return customerService.verifyPasscode(passcode: passcode).materialize()
    }
    
    public func authenticate(username: String, password: String, deviceId: String) -> Observable<Event<[String: String?]?>> {
        return authenticationService.authenticate(username: username, password: password, deviceId: deviceId).materialize()
    }
    
    public func generateLoginOTP(username: String, passcode: String, deviceId: String) -> Observable<Event<String?>> {
        customerService.generateLoginOTP(username: username, passcode: passcode, deviceID: deviceId).materialize()
    }
    
}
