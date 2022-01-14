//
//  BeneficiaryCountry.swift
//  YAP
//
//  Created by Zain on 08/05/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import UIKit

public struct SendMoneyBeneficiaryCountry: Codable {
    public let id: Int
    public let isoCode2Digit: String
    public let isoCode3Digit: String
    public let name: String
    private let _currencyList: [SendMoneyBeneficiaryCurrency]?
    private let ibanMandatory: Bool?
    public var currencyList: [SendMoneyBeneficiaryCurrency] { _currencyList ?? [] }
    public var isIbanMandatory: Bool { ibanMandatory ?? true }
    public var isSelected: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case isoCode2Digit = "isoCountryCode2Digit"
        case isoCode3Digit = "isoCountryCode3Digit"
        case name = "name"
        case _currencyList = "currencyList"
        case ibanMandatory = "ibanMandatory"
    }
}

public struct SendMoneyBeneficiaryCurrency: Codable {
    public let code: String
    public let name: String
    public let isDefault: Bool
    public let isRMT: Bool
    public let isCashPickup: Bool
    public let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case code = "code"
        case isDefault = "default"
        case isRMT = "rmtCountry"
        case isCashPickup = "cashPickUp"
        case isActive = "active"
    }
}

//extension SendMoneyBeneficiaryCurrency: SearchableDataType {
//    public var title: String {
//        "\(code)  \(name)"
//    }
//
//    public var icon: UIImage? {
//        UIImage.sharedImage(named: String(code.prefix(2)))
//    }
//
//    public var isAttributedTitle: Bool {
//        true
//    }
//
//    public var attributedTitle: NSAttributedString? {
//        let text = title
//        let attributed = NSMutableAttributedString(string: text)
////        attributed.addAttributes([.foregroundColor: UIColor.greyDark], range: (text as NSString).range(of: code))
////        attributed.addAttributes([.foregroundColor: UIColor.primaryDark], range: (text as NSString).range(of: name))
//        return attributed
//    }
//}

public extension SendMoneyBeneficiaryCountry {
    static var mocked : SendMoneyBeneficiaryCountry {
        return SendMoneyBeneficiaryCountry.init(id: 0, isoCode2Digit: "VA", isoCode3Digit: "VAT", name: "Vatican City State", _currencyList: [SendMoneyBeneficiaryCurrency.mocked], ibanMandatory: false)
    }
    
    static func from(appCountry country: AppCountry?) -> SendMoneyBeneficiaryCountry {
        SendMoneyBeneficiaryCountry.init(id: 0, isoCode2Digit: country?.alpha2Code ?? "", isoCode3Digit: "", name: country?.name ?? "", _currencyList: [], ibanMandatory: false)
    }
}

extension SendMoneyBeneficiaryCurrency {
    static var mocked : SendMoneyBeneficiaryCurrency {
        return SendMoneyBeneficiaryCurrency.init(code: "EUR", name: "Euro", isDefault: false, isRMT: false, isCashPickup: false, isActive: true)
    }
}

public extension SendMoneyBeneficiaryCountry {
    var defaultCurrency: SendMoneyBeneficiaryCurrency? {
        currencyList.filter{ $0.isDefault }.first ?? currencyList.filter{ $0.code.hasPrefix(isoCode2Digit) }.first ?? currencyList.first
    }
}

//extension SendMoneyBeneficiaryCountry: SearchableDataType {
//    public var title: String { name }
//
//    public var icon: UIImage? { UIImage.sharedImage(named: isoCode2Digit) }
//
//    public var selected: Bool { isSelected }
//}

