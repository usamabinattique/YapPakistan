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

    func getWaitingListRanking() -> Observable<Event<WaitingListRank?>> {
        let invitees: [Invitee] = [
            Invitee(inviteeCustomerId: "1", inviteeCustomerName: "Logan Pearson"),
            Invitee(inviteeCustomerId: "2", inviteeCustomerName: "Virginia Alvarado"),
            Invitee(inviteeCustomerId: "3", inviteeCustomerName: "Bruce Guerrero"),
            Invitee(inviteeCustomerId: "4", inviteeCustomerName: "Emma Weber"),
            Invitee(inviteeCustomerId: "5", inviteeCustomerName: "Nada Hassan")
        ]

        let rank = WaitingListRank(jump: "100", waitingNewRank: 1000, waitingBehind: 20, completedKyc: false, viewable: true, gainPoints: nil, inviteeDetails: invitees, totalGainedPoints: 100, waiting: false)

        return Observable.of(rank).delay(.seconds(3), scheduler: MainScheduler.instance).materialize()

//        return customersService.fetchRanking().materialize()
    }
}
