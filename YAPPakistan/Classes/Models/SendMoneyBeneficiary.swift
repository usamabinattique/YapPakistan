//
//  SendMoneyBeneficiary.swift
//  YAP
//
//  Created by Zain on 28/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

enum SendMoneyBeneficiaryType: String, Codable {
    case swift = "SWIFT"
    case rmt = "RMT"
    case cashPayout = "CASHPAYOUT"
    case domestic = "DOMESTIC"
    case uaefts = "UAEFTS"
    case IBFT = "IBFT"
}

extension SendMoneyBeneficiaryType {
    var localizeDescription: String {
        switch self {
        case .swift, .rmt, .domestic, .uaefts, .IBFT:
            return "Bank transfer"
        case .cashPayout:
            return "Cash pickup"
        }
    }
    
    var iconName: String? {
        switch self {
        case .swift, .rmt, .domestic, .uaefts:
            return "icon_edit_money_bank_transfer"
        default:
            return nil
        }
    }
    
    var productCode: TransactionProductCode {
        switch self {
        case .swift:
            return .swift
        case .rmt:
            return .rmt
        case .cashPayout:
            return .cashPayout
        case .domestic:
            return .domestic
        case .uaefts:
            return .uaeftsTransfer
        case .IBFT:
            return .domestic
        }
    }
}

public struct SendMoneyBeneficiary: Codable {
    
    var type: SendMoneyBeneficiaryType?
    public var country: String?
    var isRMTCountry: Bool?
    var isCashPickUpAvailable: Bool?
    var id: Int?
    var beneficiaryID: String?
    var nickName: String?
    public var firstName: String?
    public var lastName: String?
    var title: String?
    var currency: String?
    var phoneNumber: String?
    var IBAN: String?
    var swiftCode: String?
    var bankName: String?
    var branchName: String?
    var bankLogoUrl: String?
    var branchAddress: String?
    var identifierCode1Name: String?
    var identifierCode2Name: String?
    var identifierCode1: String?
    var identifierCode2: String?
    var accountUuid: String?
    var selectedCountry: SendMoneyBeneficiaryCountry?
    var bankCity: String?
    var index: Int?
    var cbwsiCompliant: Bool?
    var countryOfResidence: String?
    var countryOfResidenceName: String?
    var countries: [SendMoneyBeneficiaryCountry]?
    var selectedResidenceCountry: SendMoneyBeneficiaryCountry?
    var beneficiaryCreationDate: String?
    public var lastTranseferDate: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "beneficiaryType"
        case country = "country"
        case id = "id"
        case beneficiaryID = "beneficiaryId"
        case nickName = "nickName"
        case title = "title"
        case firstName = "firstName"
        case lastName = "lastName"
        case currency = "currency"
        case phoneNumber = "mobileNo"
        case IBAN = "accountNo"
        case swiftCode = "swiftCode"
        case bankName = "bankName"
        case branchName = "branchName"
        case bankLogoUrl = "bankLogoUrl"
        case branchAddress = "branchAddress"
        case identifierCode1Name = "identifierCode1Name"
        case identifierCode2Name = "identifierCode2Name"
        case identifierCode1 = "identifierCode1"
        case identifierCode2 = "identifierCode2"
        case accountUuid = "accountUuid"
        case bankCity = "bankCity"
        case cbwsiCompliant = "cbwsicompliant"
        case countryOfResidence = "countryOfResidence"
        case countryOfResidenceName = "countryOfResidenceName"
        case countries, selectedResidenceCountry
        case beneficiaryCreationDate = "beneficiaryCreationDate"
        case lastTranseferDate = "lastUsedDate"
    }
}

public extension SendMoneyBeneficiary {
    
    static var mocked: SendMoneyBeneficiary {
        return SendMoneyBeneficiary(type: .domestic, country: "GB", isRMTCountry: true, isCashPickUpAvailable: nil, id: 123, beneficiaryID: "12344", nickName: "John Doe",  firstName: "John", lastName: "Doe", title: "John Doe", currency: "GBP", phoneNumber: "(403) 292-1100", IBAN: "AE02345612344567", swiftCode: nil, bankName: "Bank Alfalah", branchName: nil, bankLogoUrl: "https://s3-eu-west-1.amazonaws.com//qa-yap-pk-documents-public/banks/Bank Alfalah.png", branchAddress: "Pakistan, 340 5TH AVE SW, CALGARY, AB", identifierCode1Name: nil, identifierCode2Name: nil, identifierCode1: nil, identifierCode2: nil, selectedCountry: nil, bankCity: nil, cbwsiCompliant: nil, lastTranseferDate: nil)
    }
    
    var fullName: String {
        return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
    
    var accountTitle : String {
        return title == nil ? "" : title as! String
    }
    
    init(_ beneficiary: SendMoneyBeneficiary, index: Int) {
        type = beneficiary.type
        country = beneficiary.country
        isRMTCountry = beneficiary.isRMTCountry
        isCashPickUpAvailable = beneficiary.isCashPickUpAvailable
        id = beneficiary.id
        beneficiaryID = beneficiary.beneficiaryID
        nickName = beneficiary.nickName
        title = beneficiary.title
        firstName = beneficiary.firstName
        lastName = beneficiary.lastName
        currency = beneficiary.currency
        phoneNumber = beneficiary.phoneNumber
        IBAN = beneficiary.IBAN
        swiftCode = beneficiary.swiftCode
        bankName = beneficiary.bankName
        branchName = beneficiary.branchName
        branchAddress = beneficiary.branchAddress
        identifierCode1Name = beneficiary.identifierCode1Name
        identifierCode2Name = beneficiary.identifierCode2Name
        identifierCode1 = beneficiary.identifierCode1
        identifierCode2 = beneficiary.identifierCode2
        accountUuid = beneficiary.accountUuid
        selectedCountry = beneficiary.selectedCountry
        bankCity = beneficiary.bankCity
        cbwsiCompliant = beneficiary.cbwsiCompliant
        countries = beneficiary.countries
        selectedResidenceCountry = beneficiary.selectedResidenceCountry
        countryOfResidence = beneficiary.countryOfResidence
        countryOfResidenceName = beneficiary.countryOfResidenceName
        beneficiaryCreationDate = beneficiary.beneficiaryCreationDate
        lastTranseferDate = beneficiary.lastTranseferDate
        self.index = index
    }
    
    var color: UIColor {
        UIColor.colorFor(listItemIndex: index ?? 0)
    }
}

extension SendMoneyBeneficiary {
    var formattedIBAN: String? {
        guard let `iban` = IBAN else { return nil }
        
        var chuncks = [String]()
        var chunck = ""
        (0..<iban.count).forEach{
            
            chunck.append(iban[$0])
            
            if $0 != 0, ($0+1) % 4 == 0 {
                chuncks.append(chunck)
                chunck = ""
            }
        }
        
        if chunck.count > 0 {
            chuncks.append(chunck)
        }
        
        return chuncks.joined(separator: " ")
    }
}

extension SendMoneyBeneficiary: YapItBeneficiary {
    public var name: String {
        fullName
    }
    
    public var countryFlag: UIImage? {
        (type ?? .domestic) == .rmt || (type ?? .domestic) == .swift ? UIImage.sharedImage(named: country!) : nil
    }
    
    public var profilePhoto: (photoUrl: String?, initialsImage: UIImage?) {
        (nil, accountTitle.initialsImage(color: color))
    }
}

// MARK: - Yap it recent beneficairy

extension SendMoneyBeneficiary: RecentBeneficiaryType {
    public var beneficiaryImage: ImageWithURL {
        (nil, accountTitle.initialsImage(color: color))
    }
    
    public var beneficiaryTitle: String? {
        if self.name == "" {
            return self.title
        }
        else {
            return self.name
        }
    }
    
    public var beneficiarySubTitle: String? {
        self.nickName
    }
    
    public var beneficiaryCountryCode: String? {
        country
    }
    
    public var beneficiaryLasTransferDate: Date {
        guard let dateString = lastTranseferDate else { return Date() }
        return DateFormatter.transferDateFormatter.date(from: dateString) ?? Date()
    }
    
    public func indexed(_ index: Int) -> RecentBeneficiaryType {
        SendMoneyBeneficiary(self, index: index)
    }
}

extension SendMoneyBeneficiary: SearchableBeneficiaryType {
    
    public var searchableTransferType: SearchableBeneficiaryTransferType {
        switch type {
        case .cashPayout:
            return .cashPayout
        case .domestic:
            return .domestic
        case .uaefts:
            return .uaefts
        case .rmt:
            return .rmt
        case .swift:
            return .swift
        default:
            return .domestic
        }
    }
    
    public var searchableTitle: String? {
        nickName
    }
    
    public var searchableSubTitle: String? {
        fullName
    }
    
    public var searchableIcon: ImageWithURL {
        (nil, fullName.initialsImage(color: color))
    }
    
    public var searchableIndicator: UIImage? {
        country != nil ? UIImage.sharedImage(named: country!) : nil
    }
    
    public func indexed(_ index: Int) -> SearchableBeneficiaryType {
        SendMoneyBeneficiary(self, index: index)
    }
}

public extension Array where Element == SendMoneyBeneficiary {
    var indexed: [Element] {
        return enumerated().map{ SendMoneyBeneficiary($0.1, index: $0.0) }
    }
}
