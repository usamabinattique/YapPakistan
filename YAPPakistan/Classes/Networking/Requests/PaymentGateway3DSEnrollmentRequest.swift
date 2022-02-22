//
//  PaymentGateway3DSEnrollmentRequest.swift
//  YAPPakistan
//
//  Created by Umair  on 21/02/2022.
//

import Foundation

struct PaymentGateway3DSEnrollmentRequest: Codable {
    let beneficiaryID: Int
    let order: PaymentGatewayAmountRequest
    let session: PaymentGatewaySessionRequest
    
    private enum CodingKeys: String, CodingKey {
        case beneficiaryID = "beneficiaryId"
        case order
        case session
    }
}