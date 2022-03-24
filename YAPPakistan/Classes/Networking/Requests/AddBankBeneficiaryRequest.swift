//
//  AddBankBeneficiaryRequest.swift
//  YAPPakistan
//
//  Created by Yasir on 21/03/2022.
//

import Foundation

public struct AddBankBeneficiaryRequest: Codable {
    
    let title: String
    let accountNo: String
    let bankName: String
    var nickName: String?
    let beneficiaryType: String
}

