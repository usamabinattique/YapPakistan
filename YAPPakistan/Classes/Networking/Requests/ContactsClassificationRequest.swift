//
//  ContactsClassificationRequest.swift
//  YAPPakistan
//
//  Created by Umair  on 14/01/2022.
//

import Foundation

public struct Contact: Codable {
    public let name: String
    public let phoneNumber: String
    public let countryCode: String
    public let email: String?
    public let photoUrl: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Contact.CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.countryCode = try container.decode(String.self, forKey: .countryCode)
        self.email = (try? container.decode(String.self, forKey: .email)) ?? ""
        self.photoUrl = (try? container.decode(String.self, forKey: .photoUrl)) ?? ""
    }
    
    init(name: String, phoneNumber: String, countryCode: String, email: String?, photoUrl: String?) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.countryCode = countryCode
        self.email = email
        self.photoUrl = photoUrl
    }
}

extension Contact: Hashable {
    
    public static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.phoneNumber == rhs.phoneNumber
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(phoneNumber)
        
    }
}

extension Contact {
    enum CodingKeys: String, CodingKey {
        case email, countryCode
        case name = "title"
        case phoneNumber = "mobileNo"
        case photoUrl = "beneficiaryPictureUrl"
    }
}
