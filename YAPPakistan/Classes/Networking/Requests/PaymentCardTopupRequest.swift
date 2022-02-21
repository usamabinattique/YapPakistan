//
//  PaymentCardTopupRequest.swift
//  YAPPakistan
//
//  Created by Umair  on 21/02/2022.
//

import Foundation

struct PaymentCardTopupRequest: Codable {
    let beneficiaryID: Int
    let order: PaymentGatewayAmountRequest
    let securityCode: String
    let threeDSecureId: String
    
    private enum CodingKeys: String, CodingKey {
        case beneficiaryID = "beneficiaryId"
        case order, securityCode
        case threeDSecureId = "3DSecureId"
    }
}
