//
//  SendMoneyBankTransferInput.swift
//  YAPPakistan
//
//  Created by Yasir on 30/03/2022.
//

import Foundation

public struct SendMoneyBankTransferInput: Codable {
    
    public let beneficiaryId: String
    public let amount: String
    public let purposeCode: String
    public let purposeReason: String
    public let remarks: String?
    public let feeAmount: String
}
