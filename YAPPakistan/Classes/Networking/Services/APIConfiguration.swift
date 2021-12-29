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

    init(environment: AppEnvironment) {
        switch environment {
        case .dev:
            self.baseURL = URL(string: "https://pk-dev.yap.co")!
        case .qa:
            self.baseURL = URL(string: "https://pk-qa.yap.co")!
        case .stg:
            self.baseURL = URL(string: "https://pk-stg.yap.co")!
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
}
