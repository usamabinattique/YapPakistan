//
//  Y2YTransferRequest.swift
//  YAPPakistan
//
//  Created by Yasir on 24/01/2022.
//

import Foundation

struct Y2YTransferRequest: Codable {
    let receiverUUID: String
    let amount: String
//    let transactionNote: String?
    let remarks: String?
    let beneficiaryName: String
    let otpVerificationReq: Bool
    let deviceId: String
}
