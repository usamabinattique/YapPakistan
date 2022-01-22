//
//  OTPRepository.swift
//  YAPKit
//
//  Created by Hussaan S on 05/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol OTPRepositoryType {
    func generateOTP(action: OTPAction, mobileNumber: String) -> Observable<Event<String?>>
    func generateLoginOTP(username: String, passcode: String, deviceId: String) -> Observable<Event<String?>>
    func verifyLoginOTP(username: String, passcode: String, deviceId: String, otp: String) -> Observable<Event<String?>>
    func generateForgotOTP(username: String) -> Observable<Event<String?>>
    func verifyForgotOTP(username: String, otp: String) -> Observable<Event<String?>>
    func verifyOTP(action: String, otp: String) -> Observable<Event<String?>>
    func generate(action: String) -> Observable<Event<String?>>
}

class OTPRepository: OTPRepositoryType {
    private let messageService: MessagesServiceType
    private let customerService: CustomerServiceType

    init(messageService: MessagesServiceType,
         customerService: CustomerServiceType) {
        self.messageService = messageService
        self.customerService = customerService
    }

    func generateOTP(action: OTPAction, mobileNumber: String) -> Observable<Event<String?>> {
        return messageService.generateOTP(action: action.rawValue, mobileNumber: mobileNumber).materialize()
    }

    func generateLoginOTP(username: String, passcode: String, deviceId: String) -> Observable<Event<String?>> {
        customerService.generateLoginOTP(username: username, passcode: passcode, deviceID: deviceId).materialize()
    }

    func verifyLoginOTP(username: String, passcode: String, deviceId: String, otp: String) -> Observable<Event<String?>> {
        customerService.verifyLoginOTP(username: username, passcode: passcode, deviceID: deviceId, otp: otp).materialize()
    }

    func generateForgotOTP(username: String) -> Observable<Event<String?>> {
        messageService.generateForgotOTP(username: username).materialize()
    }

    func verifyForgotOTP(username: String, otp: String) -> Observable<Event<String?>> {
        messageService.verifyForgotOTP(username: username, otp: otp).materialize()
    }

    func verifyOTP(action: String, otp: String) -> Observable<Event<String?>> {
        messageService.verifyOTP(action: action, otp: otp).materialize()
    }

    func generate(action: String) -> Observable<Event<String?>> {
        messageService.generateOTP(action: action).materialize()
    }
}