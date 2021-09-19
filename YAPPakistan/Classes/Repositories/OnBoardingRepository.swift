//
//  OnBoardingRepository.swift
//  YAPPakistan
//
//  Created by Tayyab on 07/09/2021.
//

import Foundation
import RxSwift

class OnBoardingRepository {
    private let customersService: CustomersService
    private let messagesService: MessagesService

    init(customersService: CustomersService, messagesService: MessagesService) {
        self.customersService = customersService
        self.messagesService = messagesService
    }

    func signUpOTP(countryCode: String, mobileNo: String, accountType: String) -> Observable<Event<String?>> {
        messagesService.signUpOTP(countryCode: countryCode, mobileNo: mobileNo, accountType: accountType).materialize()
    }

    func resendOTP(countryCode: String, mobileNo: String, accountType: String) -> Observable<Event<String?>> {
        messagesService.resendOTP(countryCode: countryCode, mobileNo: mobileNo, accountType: accountType).materialize()
    }

    func verifyOTP(countryCode: String, mobileNo: String, otp: String) -> Observable<Event<OTPData>> {
        messagesService.verifyOTP(countryCode: countryCode, mobileNo: mobileNo, otp: otp).materialize()
    }

    func signUpEmail(email: String, accountType: String, otpToken: String) -> Observable<Event<String?>> {
        customersService.signUpEmail(email: email, otpToken: otpToken, accountType: accountType).materialize()
    }

    func saveProfile(countryCode: String, mobileNo: String, passcode: String, firstName: String,
                     lastName: String, email: String, token: String, whiteListed: Bool, accountType: String) -> Observable<Event<String>> {
        customersService.saveProfile(countryCode: countryCode, mobileNo: mobileNo, passcode: passcode, firstName: firstName,
                                     lastName: lastName, email: email, token: token, whiteListed: whiteListed).materialize()
    }

    func getWaitingListRanking() -> Observable<Event<WaitingListRank?>> {
        return customersService.fetchRanking().materialize()
    }
}
