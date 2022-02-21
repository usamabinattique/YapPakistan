//
//  PaymentGateway3DSEnrollmentResult.swift
//  YAPPakistan
//
//  Created by Umair  on 21/02/2022.
//

import Foundation

struct PaymentGateway3DSEnrollmentResult: Codable {
    let html: String
    let formattedHTML: String
    let threeDSecureId: String
}

extension PaymentGateway3DSEnrollmentResult {
    
    private enum CodingKeys: String, CodingKey {
        case threeDSecure = "3DSecure"
        case threeDSecureId = "3DSecureId"
    }
    
    private enum AuthRedirectCodingKeys: String, CodingKey {
        case authenticationRedirect
    }
    
    private enum SimpleCodingKeys: String, CodingKey {
        case simple
    }
    
    private enum HTMLCodingKeys: String, CodingKey {
        case htmlBodyContent
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        threeDSecureId = try values.decode(String.self, forKey: .threeDSecureId)
        
        let threeDSecureContainer = try values.nestedContainer(keyedBy: AuthRedirectCodingKeys.self, forKey: .threeDSecure)
        let authRedirectContainer = try threeDSecureContainer.nestedContainer(keyedBy: SimpleCodingKeys.self, forKey: .authenticationRedirect)
        let simpleContainer = try authRedirectContainer.nestedContainer(keyedBy: HTMLCodingKeys.self, forKey: .simple)
        
        html = try simpleContainer.decode(String.self, forKey: .htmlBodyContent)
        
        formattedHTML = html.replacingOccurrences(of: "\\", with: "")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(threeDSecureId, forKey: .threeDSecureId)
        var threeDSecureContainer = container.nestedContainer(keyedBy: AuthRedirectCodingKeys.self, forKey: .threeDSecure)
        var authRedirectContainer = threeDSecureContainer.nestedContainer(keyedBy: SimpleCodingKeys.self, forKey: .authenticationRedirect)
        var simpleContainer = authRedirectContainer.nestedContainer(keyedBy: HTMLCodingKeys.self, forKey: .simple)
        try simpleContainer.encode(html, forKey: .htmlBodyContent)
    }
}
