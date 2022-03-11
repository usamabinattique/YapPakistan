//
//  OrderCardRequest.swift
//  YAPPakistan
//
//  Created by Umair  on 24/02/2022.
//

import Foundation

struct OrderCardRequest: Codable {
    let threeDSecureId: String
    let order: PaymentGatewayAmountRequest
    var beneficiaryId: String? = nil
    var session: PaymentGatewaySessionRequest? = nil
    let securityCode: String
    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: OrderCardRequest.CodingKeys.self)
//        self.threeDSecureId = try container.decode(String.self, forKey: .threeDSecureId)
//        self.order = (try? container.decode(PaymentGatewayAmountRequest?.self, forKey: .order))
//        self.session = (try? container.decode(PaymentGatewaySessionRequest?.self, forKey: .session))
//    }
    
    init(threeDSecureId: String, order: PaymentGatewayAmountRequest, session: PaymentGatewaySessionRequest? = nil, securityCode: String, beneficiaryId: String? = nil) {
        self.threeDSecureId = threeDSecureId
        self.order = order
        self.session = session
        self.securityCode = securityCode
        self.beneficiaryId = beneficiaryId
    }
    
    private enum CodingKeys: String, CodingKey {
        case order
        case session
        case securityCode
        case threeDSecureId = "3DSecureId"
        case beneficiaryId
        
    }
}
