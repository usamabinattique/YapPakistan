//
//  Customer.swift
//  YAP
//
//  Created by MHS on 06/12/2018.
//  Copyright © 2018 YAP. All rights reserved.
//

import Foundation
// swiftlint:disable identifier_name
public struct Customer: Codable {
    public var email: String { _email ?? "" }

    public let uuid: String
    let _email: String?
    public let countryCode: String?
    public let mobileNo: String
    public let firstName: String
    public let lastName: String
    public let companyName: String?
    public let emailVerified: Bool
    public let mobileNoVerified: Bool
    public let status: String
    public let gender: String?
    public let nationalityId: String?
    public let isEmailVerified: String?
    public let isMobileNoVerified: String?
    public let dob: String?
    public let passportNo: String?
    public let nationality: String?
    public let imageURL: URL?
    public let customerId: String?
    public let homeCountry: String?
    public let founder: Bool?
    public let customerColor: String?

    public var isFounder: Bool {
        founder ?? false
    }

    private enum CodingKeys: String, CodingKey {
        case uuid, countryCode, mobileNo, firstName, lastName, companyName, emailVerified, mobileNoVerified, status, dob, passportNo, nationality, customerId, homeCountry, customerColor
        case gender, nationalityId
        case isMobileNoVerified, isEmailVerified
        case _email = "email"
        case imageURL = "profilePictureName"
        case founder = "founder"
    }
}

public extension Customer {
    init(customer: Customer, updatedMobileNumber: String) {
        self.uuid = customer.uuid
        self._email = customer.email
        self.countryCode = customer.countryCode
        self.mobileNo = updatedMobileNumber
        self.firstName = customer.firstName
        self.lastName = customer.lastName
        self.companyName = customer.companyName
        self.emailVerified = customer.emailVerified
        self.mobileNoVerified = customer.mobileNoVerified
        self.status = customer.status
        self.dob = customer.dob
        self.passportNo = customer.passportNo
        self.nationality = customer.nationality
        self.imageURL = customer.imageURL
        self.customerId = customer.customerId
        self.homeCountry = customer.homeCountry
        self.founder = customer.founder
        self.customerColor = customer.customerColor
        self.isEmailVerified = customer.isEmailVerified
        self.isMobileNoVerified = customer.isMobileNoVerified
        self.gender = customer.gender
        self.nationalityId = customer.nationalityId
        
    }

    init(customer: Customer, updatedEmail: String) {
        self.uuid = customer.uuid
        self._email = updatedEmail
        self.countryCode = customer.countryCode
        self.mobileNo = customer.mobileNo
        self.firstName = customer.firstName
        self.lastName = customer.lastName
        self.companyName = customer.companyName
        self.emailVerified = customer.emailVerified
        self.mobileNoVerified = customer.mobileNoVerified
        self.status = customer.status
        self.dob = customer.dob
        self.passportNo = customer.passportNo
        self.nationality = customer.nationality
        self.imageURL = customer.imageURL
        self.customerId = customer.customerId
        self.homeCountry = customer.homeCountry
        self.founder = customer.founder
        self.customerColor = customer.customerColor
        self.isEmailVerified = customer.isEmailVerified
        self.isMobileNoVerified = customer.isMobileNoVerified
        self.gender = customer.gender
        self.nationalityId = customer.nationalityId
        
    }
}

public extension Customer {
    var fullName: String? {
        return (firstName.count > 0 ? firstName + " " + lastName : lastName).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
