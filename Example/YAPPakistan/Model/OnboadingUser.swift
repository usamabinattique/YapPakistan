//
//  OnboadingUser.swift
//  YAPPakistan_Example
//
//  Created by Umer on 05/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
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

public enum AccountType: String, Codable {
    case b2cAccount = "B2C_ACCOUNT"
}

public struct PhoneNumber {
    private(set) var number: String?
    private(set) var countryCode: String?
    private(set) var readableCountryCode: String?

    public var formattedValue: String? {
        didSet {
            var components = formattedValue?.components(separatedBy: " ")
            readableCountryCode = components?.first
            countryCode = components?.first?.replacingOccurrences(of: "+", with: "00")
            components?.removeFirst()
            number = components?.joined()
            number = number?.replacingOccurrences(of: "-", with: "")
        }
    }

    public var serverFormattedValue: String? {
        return (countryCode ?? "") + (number ?? "")
    }

    public init(formattedValue: String?) {
        self.formattedValue = formattedValue
    }
}

// MARK: Initialization

extension OnBoardingUser {
    init(accountType: AccountType) {
        self.accountType = accountType
        isWaiting = false
    }
}
