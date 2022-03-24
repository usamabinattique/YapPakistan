//
//  AddBankBeneficiaryResponse.swift
//  YAPPakistan
//
//  Created by Yasir on 21/03/2022.
//

import Foundation


public struct AddBankBeneficiaryResponse: Codable {
    
    public let id: Int
    public let accountUuid: String
    public let beneficiaryType: String
    public let title: String
    public let accountNo: String
    public let bankName: String
    
    public let beneficiaryCreationDate: String
    public let nickName: String?
    public let bankLogoUrl: String?
    public let bankLogoName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case accountUuid
        case beneficiaryType
        case title
        case accountNo
        case bankName
        
        case beneficiaryCreationDate
        case nickName
        case bankLogoUrl
        case bankLogoName
    }
}
