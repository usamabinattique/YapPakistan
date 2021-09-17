//
//  Customer.swift
//  YAP
//
//  Created by MHS on 06/12/2018.
//  Copyright © 2018 YAP. All rights reserved.
//

import Foundation
import PhoneNumberKit
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
    }
}

public extension Customer {
    var fullName: String? {
        return (firstName.count > 0 ? firstName + " " + lastName : lastName).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var fullMobileNo: String {
        let mobileNumber = (countryCode ?? "") + mobileNo
        return formatePhoneNumber(mobileNumber).phoneNumber
    }
    
    //var accentColor: UIColor { customerColor.map { UIColor.init(hexString: $0) } ?? .primary }
}

private extension Customer {
    func formatePhoneNumber(_ phoneNumber: String) -> (phoneNumber: String, formatted: Bool) {
        do {
            let pNumber = try PhoneNumberKit().parse(phoneNumber)
            let formattedNumber = PhoneNumberKit().format(pNumber, toType: .international)
            return (formattedNumber, true)
        } catch {
            //            print("error occurred while formatting phone number: \(error)")
        }
        let range = (phoneNumber as NSString).range(of: "00")
        if range.location == 0 {
            return ((phoneNumber as NSString).replacingCharacters(in: range, with: "+"), false)
        }
        return (phoneNumber, false)
    }
}

// MARK: - Mocked
public extension Customer {
    var homeCountry2Digit: String {
        guard let homeCountry = homeCountry else { return "AE" }
        guard homeCountry.count != 2 else { return homeCountry }
        let countryCode = ResourceManager.appCountries?.filter{ $0.alpha3Code == homeCountry }.first?.alpha2Code
        return countryCode ?? "AE"
    }
}
