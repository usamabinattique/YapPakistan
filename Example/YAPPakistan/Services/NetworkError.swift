//
//  NetworkError.swift
//  YAPPakistan_Example
//
//  Created by Umer on 13/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
struct ServerError: Codable {
    public let code: String
    public let message: String
}

struct InternalServerError: Codable {
    public let errors: [ServerError]
}

struct AuthError: Codable {
    public struct AuthErrorDetail: Codable {
        public let code: String
        public let message: String
    }
    public let error: AuthErrorDetail
}

enum NetworkError: LocalizedError {
    case noInternet
    case requestTimedOut
    case badGateway
    case notFound
    case forbidden
    case internalServerError(InternalServerError?)
    case serverError(Int, String)
    case authError(AuthError?)
    case existingEmiratesID
    case unknown
}

extension NetworkError {
    public var errorDescription: String? {
        switch self {
        case .noInternet:
            return "Looks like you're offline. Please reconnect and refresh to continue using YAP."
        case .requestTimedOut:
            return "The request is timeout!"
        case .badGateway:
            return "Bad Gateway"
        case .notFound:
            return "Resource Not Found"
        case .forbidden:
            return "You don't have access to this information"
        case .internalServerError(let serverErrors):
            if let serverErrors = serverErrors, let error = serverErrors.errors.first {
                return error.message
            }
            return "Sorry, that doesn't look right."
//            return AppTranslation.shared.translation(forKey: "common_display_text_fallback_error_message")
        case .serverError(_, let message):
            return message
        case .authError(let authError):
            if let authError = authError {
                return authError.error.message
            }
            return "Sorry, that doesn't look right."
//            return AppTranslation.shared.translation(forKey: "common_display_text_fallback_error_message")
        default:
            return "Looks like you're offline. Please reconnect and refresh to continue using YAP."
//            return AppTranslation.shared.translation(forKey: "common_display_text_fallback_error_message")
        }
    }
}

class NetworkErrorHandler {

    static func decode<T: Codable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    static func mapError(_ code: Int, data: Data) -> NetworkError {
        switch code {
        case 401:
                let authError: AuthError? = try? decode(data: data)
                return .authError(authError)
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 400...499:
                let serverErrors: InternalServerError? = try? decode(data: data)
                return .internalServerError(serverErrors)
        case 502:
            return .badGateway
        case -1009:
            return .noInternet
        case -1001:
            return .requestTimedOut
        case 1041:
            return .existingEmiratesID
        default:
            return .unknown
        }
    }
}
