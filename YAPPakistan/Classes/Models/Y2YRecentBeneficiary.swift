//
//  Y2YRecentBeneficiary.swift
//  YAP
//
//  Created by Zain on 30/04/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import YAPComponents

public struct Y2YRecentBeneficiary {
    let name: String
    let phoneNumber: String
    let photoUrl: String?
    let uuid: String
    let accountType: AccountType
    var index: Int?
    var beneficiaryCreationDate: String?
    let lastTranseferDate: String?
    let countryCode: String
}

extension Y2YRecentBeneficiary: Codable {
    
    enum CodingKeys: String, CodingKey {
        case index
        case name = "title"
        case phoneNumber = "mobileNo"
        case photoUrl = "beneficiaryPictureUrl"
        case uuid = "beneficiaryUuid"
        case accountType = "beneficiaryAccountType"
        case beneficiaryCreationDate = "beneficiaryCreationDate"
        case lastTranseferDate = "lastUsedDate"
        case countryCode = "countryCode"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Y2YRecentBeneficiary.CodingKeys.self)

        name = (try? container.decode(String?.self, forKey: .name)) ?? ""
        phoneNumber = (try? container.decode(String?.self, forKey: .phoneNumber)) ?? ""
        photoUrl = try? container.decode(String?.self, forKey: .photoUrl)
        uuid = (try? container.decode(String?.self, forKey: .uuid)) ?? ""
        lastTranseferDate = (try? container.decode(String?.self, forKey: .lastTranseferDate))
        accountType = AccountType(rawValue: (try? container.decode(String?.self, forKey: .accountType)) ?? "") ?? .b2cAccount
        countryCode = (try? container.decode(String?.self, forKey: .countryCode)) ?? "00971"
        index = 0
    }
}

extension Y2YRecentBeneficiary {
    static var mock: Y2YRecentBeneficiary {
        return Y2YRecentBeneficiary(name: "Muhammad Umair", phoneNumber: "", photoUrl: nil, uuid: "", accountType: .b2cAccount, index: 0, lastTranseferDate: nil, countryCode: "")
    }

    static func moked(withName name: String) -> Y2YRecentBeneficiary {
        return Y2YRecentBeneficiary(name: name, phoneNumber: "", photoUrl: nil, uuid: "", accountType: .b2cAccount, index: nil, lastTranseferDate: nil, countryCode: "")
    }
}

// MARK: - Yap it recent beneficiary

extension Y2YRecentBeneficiary: RecentBeneficiaryType {
    
    private func thumbnail(forIndex index: Int) -> UIImage? {
        let colorIndex = index % 4
        return name.initialsImage(color: colorIndex == 0 ? .magenta : colorIndex == 1 ? .green.withAlphaComponent(0.50) : colorIndex == 2 ? .blue.withAlphaComponent(0.50) : .orange.withAlphaComponent(0.50), font: UIFont.systemFont(ofSize: 11.0))
        //return name.initialsImage(color: colorIndex == 0 ? .secondaryMagenta : colorIndex == 1 ? .secondaryGreen : colorIndex == 2 ? .secondaryBlue : .secondaryOrange)
    }
    
    public var beneficiaryImage: ImageWithURL {
        (photoUrl, thumbnail(forIndex: index ?? 0))
    }
    
    public var beneficiaryTitle: String? {
        self.name
    }
    
    public var beneficiarySubTitle: String? {
        self.phoneNumber
    }
    
    public var beneficiaryPackage: RecentBeneficiaryPackage {
        .prime
    }
    
    public var beneficiaryLasTransferDate: Date {
        guard let dateString = lastTranseferDate else { return Date() }
        return DateFormatter.transferDateFormatter.date(from: dateString) ?? Date()
    }
    
    public func indexed(_ index: Int) -> RecentBeneficiaryType {
        Y2YRecentBeneficiary(self, index: index)
    }
    
    public init(_ beneficiary: Y2YRecentBeneficiary, index: Int) {
        name = beneficiary.name
        phoneNumber = beneficiary.phoneNumber
        photoUrl = beneficiary.photoUrl
        uuid = beneficiary.uuid
        accountType = beneficiary.accountType
        self.index = index
        beneficiaryCreationDate = beneficiary.beneficiaryCreationDate
        lastTranseferDate = beneficiary.lastTranseferDate
        countryCode = beneficiary.countryCode
    }
}

extension Y2YRecentBeneficiary: SearchableBeneficiaryType {
    public func indexed(_ index: Int) -> SearchableBeneficiaryType {
        Y2YRecentBeneficiary(self, index: index)
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
        beneficiaryPackage.image
    }
}


public extension Array where Element == Y2YRecentBeneficiary {
    var indexed: [Element] {
        return enumerated().map{ Y2YRecentBeneficiary($0.1, index: $0.0) }
    }
}

