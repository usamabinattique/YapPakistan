//
//  Contact.swift
//  YAP
//
//  Created by Zain on 17/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import Contacts
import YAPComponents
import PhoneNumberKit

public struct YAPContact: Equatable {
    
    public let name: String
    public let phoneNumber: String
    public let countryCode: String
    public let email: String?
    public let isYapUser: Bool
    public let photoUrl: String?
    public let yapAccountDetails: [ContactYAPAccountDetails]?
    public var thumbnailData: Data?
    public let index: Int?
    
    public static func contact(name: String, phoneNumber: String, countryCode: String, isYapUser: Bool, photoUrl: String?, yapAccountDetails: [ContactYAPAccountDetails]?, index: Int?) -> YAPContact {
        YAPContact(name: name, phoneNumber: phoneNumber, countryCode: countryCode, email: nil, isYapUser: isYapUser, photoUrl: photoUrl, yapAccountDetails: yapAccountDetails, thumbnailData: nil, index: index)
    }
    
    public static func == (lhs: YAPContact, rhs: YAPContact) -> Bool {
        guard let lhsUUID = lhs.yapAccountDetails?.first?.uuid,
            let rhsUUID = rhs.yapAccountDetails?.first?.uuid else { return false }
        return lhsUUID.lowercased() == rhsUUID.lowercased()
    }
    
    public static var mock: [YAPContact] = [YAPContact(name: "Test1", phoneNumber: "+923001231231", countryCode: "0092", email: nil, isYapUser: true, photoUrl: nil, yapAccountDetails: nil, thumbnailData: nil, index: nil),
                                            YAPContact(name: "Test2", phoneNumber: "+923001231232", countryCode: "0092", email: nil, isYapUser: true, photoUrl: nil, yapAccountDetails: nil, thumbnailData: nil, index: nil),
                                            YAPContact(name: "Test3", phoneNumber: "+923001231233", countryCode: "0092", email: nil, isYapUser: false, photoUrl: nil, yapAccountDetails: nil, thumbnailData: nil, index: nil),
                                            YAPContact(name: "Test4", phoneNumber: "+923001231234", countryCode: "0092", email: nil, isYapUser: true, photoUrl: nil, yapAccountDetails: nil, thumbnailData: nil, index: nil),
                                            YAPContact(name: "Test5", phoneNumber: "+923001231235", countryCode: "0092", email: nil, isYapUser: false, photoUrl: nil, yapAccountDetails: nil, thumbnailData: nil, index: nil),
                                            YAPContact(name: "Test6", phoneNumber: "+923001231236", countryCode: "0092", email: nil, isYapUser: true, photoUrl: nil, yapAccountDetails: nil, thumbnailData: nil, index: nil),
                                            YAPContact(name: "Test7", phoneNumber: "+923001231237", countryCode: "0092", email: nil, isYapUser: true, photoUrl: nil, yapAccountDetails: nil, thumbnailData: nil, index: nil)]
}

extension YAPContact: Codable {
    enum CodingKeys: String, CodingKey {
        case email, countryCode, thumbnailData, index
        case name = "title"
        case phoneNumber = "mobileNo"
        case isYapUser = "yapUser"
        case photoUrl = "beneficiaryPictureUrl"
        case yapAccountDetails = "accountDetailList"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: YAPContact.CodingKeys.self)
        self.name = (try? container.decode(String?.self, forKey: .name)) ?? ""
        self.phoneNumber = (try? container.decode(String?.self, forKey: .phoneNumber)) ?? ""
        self.countryCode = (try? container.decode(String?.self, forKey: .countryCode)) ?? ""
        self.email = try? container.decode(String?.self, forKey: .countryCode)
        self.isYapUser = (try? container.decode(Bool?.self, forKey: .isYapUser)) ?? false
        self.photoUrl = try? container.decode(String?.self, forKey: .photoUrl)
        self.thumbnailData = try? container.decode(Data?.self, forKey: .thumbnailData)
        self.index = try? container.decode(Int?.self, forKey: .index)
        self.yapAccountDetails = try? container.decode([ContactYAPAccountDetails]?.self, forKey: .yapAccountDetails)
    }
}

public extension YAPContact {
    var formattedPhoneNumber: String {
        return countryCode.replacingOccurrences(of: "00", with: "+") + " " + phoneNumber
    }

    var fullPhoneNumber: String {
        return countryCode + phoneNumber
    }

    static func contact(fromRecentBeneficiary beneficiary: Y2YRecentBeneficiary) -> YAPContact {
        YAPContact(name: beneficiary.name, phoneNumber: beneficiary.phoneNumber, countryCode: beneficiary.countryCode, email: nil, isYapUser: true, photoUrl: beneficiary.photoUrl, yapAccountDetails: [ContactYAPAccountDetails(accountType: beneficiary.accountType, accountNumber: nil, uuid: beneficiary.uuid, beneficiaryCreationDate: beneficiary.beneficiaryCreationDate)], thumbnailData: nil, index: beneficiary.index)
    }

    var thumbnailImage: UIImage? {
        thumbnail(forIndex: index ?? 0)
    }

    func thumbnail(forIndex index: Int) -> UIImage? {
        let color = UIColor.colorFor(listItemIndex: index)
        return thumbnailData != nil ? UIImage.init(data: thumbnailData!) : name.initialsImage(color: color)
    }

    mutating func setThumbnailData(_ data: Data?) {
        self.thumbnailData = data
    }
}


// MARK: Contact account details

public struct ContactYAPAccountDetails {
    public let accountType: AccountType
    public let accountNumber: String?
    public let uuid: String
    public let beneficiaryCreationDate: String?
    
    public static func accountDetails(accountType: AccountType, accountNumber: String?, uuid: String, beneficiaryCreationDate: String?) -> ContactYAPAccountDetails {
        ContactYAPAccountDetails(accountType: accountType, accountNumber: accountNumber, uuid: uuid, beneficiaryCreationDate: beneficiaryCreationDate)
    }
    
}

extension ContactYAPAccountDetails: Codable {

    enum CodingKeys: String, CodingKey {
        case accountType
        case accountNumber = "accountNo"
        case uuid = "accountUuid"
        case beneficiaryCreationDate = "beneficiaryCreationDate"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContactYAPAccountDetails.CodingKeys.self)
        self.accountType = AccountType(rawValue: (try? container.decode(String?.self, forKey: .accountType)) ?? "") ?? .b2cAccount
        self.accountNumber = (try? container.decode(String?.self, forKey: .accountNumber)) ?? ""
        self.uuid = (try? container.decode(String?.self, forKey: .uuid)) ?? ""
        self.beneficiaryCreationDate = (try? container.decode(String?.self, forKey: .beneficiaryCreationDate)) ?? ""
    }
}


extension YAPContact: YapItBeneficiary {
    public var countryFlag: UIImage? {
        nil
    }

    public var profilePhoto: (photoUrl: String?, initialsImage: UIImage?) {
        (photoUrl, thumbnailImage)
    }
}

extension YAPContact: SearchableBeneficiaryType {
    public func indexed(_ index: Int) -> SearchableBeneficiaryType {
        YAPContact.init(name: name, phoneNumber: phoneNumber, countryCode: countryCode, email: email, isYapUser: isYapUser, photoUrl: photoUrl, yapAccountDetails: yapAccountDetails, thumbnailData: thumbnailData, index: index)
    }
    
    public var searchableTransferType: SearchableBeneficiaryTransferType {
        return .y2y
    }
    
    public var searchableTitle: String? {
        name
    }
    
    public var searchableSubTitle: String? {
        "\(countryCode.replacingOccurrences(of: "00", with: "+")) \(phoneNumber)"
    }
    
    public var searchableIcon: ImageWithURL {
        (photoUrl, thumbnail(forIndex: index ?? 0))
    }
    
    public var searchableIndicator: UIImage? {
        RecentBeneficiaryPackage.prime.image
    }
}
