//
//  OTPRepository.swift
//  YAPKit
//
//  Created by Hussaan S on 05/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

public protocol OTPRepositoryType {
    func generateOTP(action: OTPAction, mobileNumber: String) -> Observable<Event<String?>>
    func generateLoginOTP(username: String, passcode: String, deviceId: String) -> Observable<Event<String?>>
    func verifyLoginOTP(username: String, passcode: String, deviceId: String, otp: String) -> Observable<Event<String?>>
}

public class OTPRepository: OTPRepositoryType {
    
    private let messageService: MessageServiceType
    private let customerService: CustomerServiceType
    
    public init(messageService: MessageServiceType,
                customerService: CustomerServiceType) {
        self.messageService = messageService
        self.customerService = customerService
    }
        
    public func generateOTP(action: OTPAction, mobileNumber: String) -> Observable<Event<String?>> {
        return messageService.generateOTP(action: action.rawValue, mobileNumber: mobileNumber).materialize()
    }
    
    public func generateLoginOTP(username: String, passcode: String, deviceId: String) -> Observable<Event<String?>> {
        customerService.generateLoginOTP(username: username, passcode: passcode, deviceID: deviceId).materialize()
    }
    
    public func verifyLoginOTP(username: String, passcode: String, deviceId: String, otp: String) -> Observable<Event<String?>> {
        customerService.verifyLoginOTP(username: username, passcode: passcode, deviceID: deviceId, otp: otp).materialize()
    }
}
