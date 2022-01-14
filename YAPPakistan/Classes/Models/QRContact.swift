//
//  QRContact.swift
//  YAP
//
//  Created by Zain on 07/11/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation

struct QRContact {
    let firstName: String
    let lastName: String
    let mobileNo: String
    let countryCode: String
    let accountUUID: String
    let url: String
}

extension QRContact: Codable {
    enum CodingKeys: String, CodingKey {
        case firstName = "firstName"
        case lastName = "lastName"
        case mobileNo = "mobileNo"
        case countryCode = "countryCode"
        case accountUUID = "uuid"
        case url = "profilePictureName"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: QRContact.CodingKeys.self)
        self.firstName = (try? container.decode(String?.self, forKey: .firstName)) ?? ""
        self.lastName = (try? container.decode(String?.self, forKey: .lastName)) ?? ""
        self.mobileNo = (try? container.decode(String?.self, forKey: .mobileNo)) ?? ""
        self.countryCode = (try? container.decode(String?.self, forKey: .countryCode)) ?? ""
        self.accountUUID = (try? container.decode(String?.self, forKey: .accountUUID)) ?? ""
        self.url = (try? container.decode(String?.self, forKey: .url)) ?? ""
    }
}

// MARK: - Mapping

extension QRContact {
    var fullName: String {
        [firstName, lastName].filter{ !$0.isEmpty }.joined(separator: " ")
    }
    
    var yapContact: YAPContact {
        YAPContact.contact(name: fullName, phoneNumber: mobileNo, countryCode: countryCode, isYapUser: true, photoUrl: url, yapAccountDetails: [ContactYAPAccountDetails.accountDetails(accountType: .b2cAccount, accountNumber: nil, uuid: accountUUID, beneficiaryCreationDate: nil)], index: 0)
    }
}
