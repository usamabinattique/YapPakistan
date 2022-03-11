//
//  PaymentGateway3DSEnrollmentRequest.swift
//  YAPPakistan
//
//  Created by Umair  on 21/02/2022.
//

import Foundation

struct PaymentGateway3DSEnrollmentRequest: Codable {
    var beneficiaryID: Int? = nil
    let order: PaymentGatewayAmountRequest
    var session: PaymentGatewaySessionRequest? = nil
    
    private enum CodingKeys: String, CodingKey {
        case beneficiaryID = "beneficiaryId"
        case order
        case session
    }
    
    init(beneficiaryID: Int? = nil, order: PaymentGatewayAmountRequest, session: PaymentGatewaySessionRequest? = nil) {
        self.beneficiaryID = beneficiaryID
        self.order = order
        self.session = session
    }
}
