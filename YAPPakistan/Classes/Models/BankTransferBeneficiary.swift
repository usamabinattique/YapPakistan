//
//  BankTransferBeneficiary.swift
//  YAPPakistan
//
//  Created by Awais on 14/03/2022.
//

import Foundation

public struct BankTransferBeneficiary: Codable {
    let id: Int
    let beneficiaryType, title, accountNo, bankName: String
    let beneficiaryCreationDate, nickName: String
    let bankLogoURL: String

    enum CodingKeys: String, CodingKey {
        case id, beneficiaryType, title, accountNo, bankName, beneficiaryCreationDate, nickName
        case bankLogoURL = "bankLogoUrl"
    }
}
