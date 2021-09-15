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
        return messagesService.signUpOTP(countryCode: countryCode, mobileNo: mobileNo, accountType: accountType).materialize()
    }

    func resendOTP(countryCode: String, mobileNo: String, accountType: String) -> Observable<Event<String?>> {
        return messagesService.resendOTP(countryCode: countryCode, mobileNo: mobileNo, accountType: accountType).materialize()
    }

    func verifyOTP(countryCode: String, mobileNo: String, otp: String) -> Observable<Event<OTPData>> {
        return messagesService.verifyOTP(countryCode: countryCode, mobileNo: mobileNo, otp: otp).materialize()
    }

    func signUpEmail(email: String, accountType: String, otpToken: String) -> Observable<Event<String?>> {
        return customersService.signUpEmail(email: email, otpToken: otpToken, accountType: accountType).materialize()
    }

    func saveProfile(countryCode: String, mobileNo: String, passcode: String, firstName: String, lastName: String, email: String, token: String, whiteListed: Bool, accountType: String) -> Observable<Event<String>> {
        return customersService.saveProfile(countryCode: countryCode, mobileNo: mobileNo, passcode: passcode, firstName: firstName, lastName: lastName, email: email, token: token, whiteListed: whiteListed).materialize()
    }

    func saveInvite(inviterCustomerId: String, referralDate: String) -> Observable<Event<String?>> {
        return customersService.saveInvite(inviterCustomerId: inviterCustomerId, referralDate: referralDate).materialize()
    }

    func getWaitingListRanking() -> Observable<Event<WaitingListRank?>> {
        return customersService.fetchRanking().materialize()
    }

    func saveReferralInvitation(inviterCustomerId: String, referralDate: String) -> Observable<Event<String?>> {
        return customersService.saveReferralInvitation(inviterCustomerId: inviterCustomerId, referralDate: referralDate).materialize()
    }
}
