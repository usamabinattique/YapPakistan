//
//  LoginRepository.swift
//  YAP
//
//  Created by Wajahat Hassan on 02/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

public protocol LoginRepositoryType: AnyObject {
    func verifyUser(username: String) -> Observable<Event<Bool>>
    func verifyPasscode(passcode: String) -> Observable<Event<String?>>
    func updatePasscode(newPasscode: String, token : String) -> Observable<Event<String?>>
    func authenticate(username: String, password: String, deviceId: String) -> Observable<Event<[String: String?]?>>
    func generateLoginOTP(username: String, passcode: String, deviceId: String) -> Observable<Event<String?>>
    func logout(deviceUUID: String) -> Observable<Event<[String: String]?>>
    func changeProfilePhoto(_ data: Data, name: String, fileName: String, mimeType: String) -> Observable<Event<ProfilePhotoResponse>>
    func removeProfilePhoto() -> Observable<Event<String?>>
    func getSocialMediaLinks() -> Observable<Event<[SocialMedia]>>
}

public class LoginRepository: LoginRepositoryType {
    
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
    
    public func updatePasscode(newPasscode: String, token : String) -> Observable<Event<String?>> {
        return customerService.updatePasscode(newPasscode: newPasscode, token: token).materialize()
    }
    
    public func changeProfilePhoto(_ data: Data, name: String, fileName: String, mimeType: String) -> Observable<Event<ProfilePhotoResponse>> {
        return customerService.uploadProfilePhoto(data: data, name: name, fileName: fileName, mimeType: mimeType, progressObserver: nil).materialize()
    }
    
    
    public func removeProfilePhoto() -> Observable<Event<String?>> {
        return customerService.removeProfilePhoto().materialize()
    }
    
    public func authenticate(username: String, password: String, deviceId: String) -> Observable<Event<[String: String?]?>> {
        return authenticationService.authenticate(username: username, password: password, deviceId: deviceId).materialize()
    }
    
    public func generateLoginOTP(username: String, passcode: String, deviceId: String) -> Observable<Event<String?>> {
        customerService.generateLoginOTP(username: username, passcode: passcode, deviceID: deviceId).materialize()
    }

    public func logout(deviceUUID: String) -> Observable<Event<[String: String]?>> {
        return authenticationService.logout(deviceUUID: deviceUUID).materialize()
    }
    
    public func getSocialMediaLinks() -> Observable<Event<[SocialMedia]>> {
        return authenticationService.getSocialMediaLinks().materialize()
    }
}
