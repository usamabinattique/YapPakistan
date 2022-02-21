//
//  PaymentGatewayAmountRequest.swift
//  YAPPakistan
//
//  Created by Umair  on 20/02/2022.
//

import Foundation

struct PaymentGatewayRequest: Codable {
    let order: PaymentGatewayAmountRequest
    let session: PaymentGatewaySessionRequest
}

struct PaymentGatewayAmountRequest: Codable {
    let id: String
    let amount: String
    let currency: String
}

struct PaymentGatewaySessionRequest: Codable {
    let id: String
}

struct CreatePaymentGatewaySessionRequest: Codable {
    let id: String
    let number: String
}
