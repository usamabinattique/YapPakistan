//
//  User.swift
//  YAP
//
//  Created by Zain on 28/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

struct OnBoardingUser {
    var countryCode: String?
    var accountType: AccountType
    var firstName: String?
    var lastName: String?
    var email: String?
    var companyName: String?
    var mobileNo: PhoneNumber = PhoneNumber(formattedValue: nil)
    var passcode: String?
    var iban: String?
    var timeTaken: TimeInterval = 0
    var otpVerificationToken: String?
    var isWaiting: Bool
}

// MARK: Initialization

extension OnBoardingUser {
    init(accountType: AccountType) {
        self.accountType = accountType
        isWaiting = false
    }
}
