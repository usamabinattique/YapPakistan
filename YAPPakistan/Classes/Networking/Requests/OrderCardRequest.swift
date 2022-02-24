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
    let session: PaymentGatewaySessionRequest
    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: OrderCardRequest.CodingKeys.self)
//        self.threeDSecureId = try container.decode(String.self, forKey: .threeDSecureId)
//        self.order = (try? container.decode(PaymentGatewayAmountRequest?.self, forKey: .order))
//        self.session = (try? container.decode(PaymentGatewaySessionRequest?.self, forKey: .session))
//    }
    
    init(threeDSecureId: String, order: PaymentGatewayAmountRequest, session: PaymentGatewaySessionRequest) {
        self.threeDSecureId = threeDSecureId
        self.order = order
        self.session = session
    }
    
    private enum CodingKeys: String, CodingKey {
        case threeDSecureId = "3DSecureId"
        case order
        case session
        
    }
}
