//
//  KYCCardBenefitsM.swift
//  YAPPakistan
//
//  Created by Umair  on 07/02/2022.
//

import Foundation

public struct KYCCardBenefitsM: Codable{
    
    var benefitID: Int
    var scheme: String
    var description: String
    var isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case benefitID = "id"
        case scheme
        case description
        case isActive
    }
    
    public init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)
        
        self.benefitID = (try? data.decode(Int?.self, forKey: .benefitID)) ?? 0
        self.scheme = (try? data.decode(String?.self, forKey: .scheme)) ?? ""
        self.description = (try? data.decode(String?.self, forKey: .description)) ?? ""
        self.isActive = (try? data.decode(Bool?.self, forKey: .isActive)) ?? false
    }
    
}
