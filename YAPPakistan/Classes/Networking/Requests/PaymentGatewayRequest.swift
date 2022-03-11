//
//  PaymentGatewayAmountRequest.swift
//  YAPPakistan
//
//  Created by Umair  on 20/02/2022.
//

import Foundation

struct PaymentGatewayRequest: Codable {
    let order: PaymentGatewayAmountRequest
    var session: PaymentGatewaySessionRequest? = nil
}

struct PaymentGatewayAmountRequest: Codable {
    var id: String? = nil
    let amount: String
    let currency: String
}

struct PaymentGatewaySessionRequest: Codable {
    var id: String? = nil
}

struct CreatePaymentGatewaySessionRequest: Codable {
    let id: String
    let number: String
}
