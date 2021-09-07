//
//  APIConfiguration.swift
//  YAPPakistan
//
//  Created by Tayyab on 24/08/2021.
//

import Foundation

public struct APIConfiguration {
    public let environment: String
    
    public var baseURL: URL {
        URL(string: "https://pk-dev.yap.co")!
    }

    public var messagesURL: URL {
        return baseURL.appendingPathComponent("/messages")
    }

    public var customersURL: URL {
        return baseURL.appendingPathComponent("/customers")
    }
}
