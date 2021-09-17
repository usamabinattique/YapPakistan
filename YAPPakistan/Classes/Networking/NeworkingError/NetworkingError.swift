//
//  NetworkingError.swift
//  Networking
//
//  Created by Zain on 01/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public enum NetworkingError: LocalizedError {
    case noInternet
    case requestTimedOut
    case badGateway
    case notFound
    case forbidden
    case internalServerError(NetworkingInternalServerError?)
    case serverError(Int, String)
    case authError(NetworkingAuthError?)
    case unknown
    
    public static func fromWebClientError(_ webClientError: WebClientError?) -> NetworkingError? {
        guard  let `webClientError` = webClientError else { return nil }
        
        switch webClientError {
        case .noInternet:
            return .noInternet
        case .requestTimedOut:
            return requestTimedOut
        case .badGateway:
            return badGateway
        case .notFound:
            return .notFound
        case .forbidden:
            return .forbidden
        case .internalServerError(let error):
            return .internalServerError(NetworkingInternalServerError(errors: error?.errors.map { NetworkingServerError(code: $0.code, message: $0.message)} ?? []))
        case .serverError(let code, let message):
            return .serverError(code, message)
        case .authError(let error):
            return .authError(NetworkingAuthError(error: NetworkingAuthError.AuthErrorDetail(code: error?.error.code ?? "", message: error?.error.message ?? "")))
        case .unknown:
            return .unknown
        }
    }
}

// MARK: Localization

extension NetworkingError {
    public var errorDescription: String? {
        switch self {
        case .noInternet:
            return "Looks like you're offline. Please reconnect and refresh to continue using YAP."
        case .requestTimedOut:
            return "Request timed out"  // TODO: add localized error description here
        case .badGateway:
            return "Bad gateway"        // TODO: add localized error description here
        case .notFound:
            return "Not found"          // TODO: add localized error description here
        case .forbidden:
            return "Forbidden"          // TODO: add localized error description here
        case .internalServerError(let error):
            return error?.errors.first?.message
        case .serverError(_, let message):
            return message
        case .authError(let error):
            return error?.error.message
        case .unknown:
            return "Unknown"            // TODO: add localized error description here
        }
    }
}

public struct NetworkingServerError: Codable {
    public let code: String
    public let message: String
}

public struct NetworkingInternalServerError: Codable {
    public let errors: [NetworkingServerError]
}

public struct NetworkingAuthError: Codable {
    public struct AuthErrorDetail: Codable {
        public let code: String
        public let message: String
    }
    public let error: AuthErrorDetail
}

public var baseUrl = BaseURL
public var adminBaseUrl = baseURLAdmin
