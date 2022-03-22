//
//  APIConfiguration.swift
//  YAPPakistan
//
//  Created by Tayyab on 24/08/2021.
//

import Foundation
import YAPCore

public struct APIConfiguration {
    public let baseURL: URL
    private let environment: AppEnvironment

    init(environment: AppEnvironment) {
        self.environment = environment
        switch environment {
        case .dev:
            self.baseURL = URL(string: "https://pk-dev.yap.co")!
        case .qa:
            //self.baseURL = URL(string: "https://pk-qa.yap.co")!
            self.baseURL = URL(string: "https://pk-stg1.yap.co/")!
        case .stg:
            self.baseURL = URL(string: "https://pk-stg1.yap.co/")! //URL(string: "https://pk-stg.yap.co")!
        case .preprod:
            self.baseURL = URL(string: "https://pk-preprod.yap.com")!
        case .prod:
            self.baseURL = URL(string: "https://pk-prod.yap.com")!
        }
    }

    public var authURL: URL {
        return baseURL.appendingPathComponent("/auth")
    }

    public var messagesURL: URL {
        return baseURL.appendingPathComponent("/messages")
    }

    public var customersURL: URL {
        return baseURL.appendingPathComponent("/customers")
    }

    public var cardsURL: URL {
        return baseURL.appendingPathComponent("/cards")
    }

    public var transactionsURL: URL {
        return baseURL.appendingPathComponent("/transactions")
    }
    
    public var onBoardingCardDetailWebURL: String {
        switch self.environment {
        case .dev:
            return "https://pk-dev-hci.yap.co/YAP_PK_BANK_ALFALAH/HostedSessionIntegration.html"
        case .qa:
            return "https://pk-qa-hci.yap.co/YAP_PK_BANK_ALFALAH/HostedSessionIntegration.html"
        case .stg:
            return "https://pk-stg-hci.yap.co/YAP_PK_BANK_ALFALAH/HostedSessionIntegration.html"
        case .preprod:
            return ""
        case .prod:
            return ""
        }
    }
    
    public var topUpCardDetailWebURL: String {
        switch self.environment {
        case .dev:
            return "https://pk-dev-hci.yap.co/admin-web/HostedSessionIntegration.html"
        case .qa:
            return "https://pk-qa-hci.yap.co/admin-web/HostedSessionIntegration.html"
        case .stg:
            return "https://pk-stg-hci.yap.co/admin-web/HostedSessionIntegration.html"
        case .preprod:
            return ""
        case .prod:
            return ""
        }
    }
}
