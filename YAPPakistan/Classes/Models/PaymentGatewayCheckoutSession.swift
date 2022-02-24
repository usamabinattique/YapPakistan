//
//  PaymentGatewayCheckoutSession.swift
//  YAPPakistan
//
//  Created by Umair  on 21/02/2022.
//

import Foundation

struct PaymentGatewayCheckoutSession: Codable {
    
    let beneficiaryId: String
    let apiOperation: String
    let interaction: String
    let error: String
    let securityCode: String
    let threeDSecureId: String
    let order: PaymentGatewayOrder?
    let session: PaymentGatewaySession?
    
    enum CodingKeys: String, CodingKey {
        case beneficiaryId
        case apiOperation
        case interaction
        case error
        case securityCode
        case threeDSecureId = "3DSecureId"
        case order
        case session
    }
    
    public init(beneficiaryId: String,apiOperation: String, interaction: String, error: String, securityCode: String,threeDSecureId: String, order: PaymentGatewayOrder? = nil, session: PaymentGatewaySession? = nil) {
        self.beneficiaryId = beneficiaryId
        self.apiOperation = apiOperation
        self.interaction = interaction
        self.error = error
        self.securityCode =  securityCode
        self.threeDSecureId = threeDSecureId
        self.order = order
        self.session = session
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentGatewayCheckoutSession.CodingKeys.self)
        
        beneficiaryId = (try? container.decode(String?.self, forKey: .beneficiaryId)) ?? ""
        apiOperation = (try? container.decode(String?.self, forKey: .apiOperation)) ?? ""
        interaction = (try? container.decode(String?.self, forKey: .interaction)) ?? ""
        error = (try? container.decode(String?.self, forKey: .error)) ?? ""
        securityCode = (try? container.decode(String?.self, forKey: .securityCode)) ?? ""
        threeDSecureId = (try? container.decode(String?.self, forKey: .threeDSecureId)) ?? ""
        order = (try? container.decode(PaymentGatewayOrder?.self, forKey: .order))
        session = (try? container.decode(PaymentGatewaySession?.self, forKey: .session))
    }
    
}

struct PaymentGatewayOrder: Codable {
    let id: String
    let currency: String
    let amount: String
    let creationTime: String
    let totalAuthorizedAmount: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case currency
        case amount
        case creationTime
        case totalAuthorizedAmount
        case status
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentGatewayOrder.CodingKeys.self)
        
        id = (try? container.decode(String?.self, forKey: .id)) ?? ""
        currency = (try? container.decode(String?.self, forKey: .currency)) ?? ""
        amount = (try? container.decode(String?.self, forKey: .amount)) ?? ""
        creationTime = (try? container.decode(String?.self, forKey: .creationTime)) ?? ""
        totalAuthorizedAmount = (try? container.decode(String?.self, forKey: .totalAuthorizedAmount)) ?? ""
        status = (try? container.decode(String?.self, forKey: .status)) ?? ""
    }
    
    public init(id: String,
        currency: String,
        amount: String,
        creationTime: String,
        totalAuthorizedAmount: String,
                status: String) {
        self.id = id
        self.currency = currency
        self.amount = amount
        self.creationTime = creationTime
        self.totalAuthorizedAmount = totalAuthorizedAmount
        self.status = status
    }
    
    
}

struct PaymentGatewaySession: Codable {
    let id: String
    let updateStatus: String
    let version: String
    let authenticationLimit: String
    let aes256Key: String
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case updateStatus
        case version
        case authenticationLimit
        case aes256Key
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentGatewaySession.CodingKeys.self)
        
        id = (try? container.decode(String?.self, forKey: .id)) ?? ""
        updateStatus = (try? container.decode(String?.self, forKey: .updateStatus)) ?? ""
        version = (try? container.decode(String?.self, forKey: .version)) ?? ""
        authenticationLimit = (try? container.decode(String?.self, forKey: .authenticationLimit)) ?? ""
        aes256Key = (try? container.decode(String?.self, forKey: .aes256Key)) ?? ""
    }
    
    public init(
        id: String,
        updateStatus: String,
        version: String,
        authenticationLimit: String,
        aes256Key: String) {
            
            self.id = id
            self.updateStatus = updateStatus
            self.version = version
            self.authenticationLimit = authenticationLimit
            self.aes256Key = aes256Key
            
        }
}

