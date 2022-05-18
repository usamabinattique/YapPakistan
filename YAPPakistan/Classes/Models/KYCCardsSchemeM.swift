//
//  KYCCardsSchemeM.swift
//  YAPPakistan
//
//  Created by Umair  on 03/02/2022.
//

import Foundation

public enum SchemeType: String, Hashable, Codable {
    case Mastercard = "Mastercard"
    case PayPak = "PayPak"
}

public struct KYCCardsSchemeM: Codable {
    
    public var schemeName: String
    public var schemeCode: String
    public var isActive: Bool
    public var fee: Double
    public var fedFee: Double?
    
    public var isPaidScheme: Bool {
         return fee > 0
    }
    
    public var totalFee: Double {
        return fee+(fedFee ?? 0)
    }
    
    public var scheme: SchemeType? { SchemeType(rawValue: schemeName ) }
    public var cardTitle: String?
    public var cardDescription: String?
    public var cardButtonTitle: String?
    public var cardImage: String?
    public var cardBackgroundColor: String?
    
    public var feeValue: String {
        return String(format: "PKR %.2f", fee)
    }
    
    public var orderValue: String {
        return "Place order for PKR \(fee)"
    }
    
    enum CodingKeys: String, CodingKey {
        case schemeName
        case schemeCode
        case isActive
        case fee
    }
    
    public init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)
        
        self.schemeName = (try? data.decode(String?.self, forKey: .schemeName)) ?? ""
        self.schemeCode = (try? data.decode(String?.self, forKey: .schemeCode)) ?? ""
        self.isActive = (try? data.decode(Bool?.self, forKey: .isActive)) ?? false
        self.fee = (try? data.decode(Double?.self, forKey: .fee)) ?? 0
        
        setupCustomProperties()
    }
    
}

extension KYCCardsSchemeM {
    mutating func setupCustomProperties() {
        switch scheme {
        case .Mastercard:
            cardTitle = "screen_kyc_card_scheme_title_mastercard".localized
            cardImage = "yap-master-card"
        case .PayPak:
            cardTitle = "screen_kyc_card_scheme_title_paypak".localized
            cardImage = "yap-paypak-card"
        default:
            cardTitle = ""
        }
        
        if fee > 0.0 {
            cardDescription = String(format: "screen_kyc_card_scheme_description_with_fee".localized, "\(fee)")
            cardButtonTitle = "screen_kyc_card_scheme_button_buy_now".localized
        } else {
            cardDescription = "screen_kyc_card_scheme_description_free".localized
            cardButtonTitle = "screen_kyc_card_scheme_button_free".localized
        }
    }
}
