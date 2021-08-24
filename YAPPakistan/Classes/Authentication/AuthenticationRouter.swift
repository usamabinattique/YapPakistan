//
//  AuthService.swift
//  YAP
//
//  Created by Muhammad Hassan on 21/02/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

enum AuthRouter<T: Codable>: YAPURLRequestConvertible, Convertible {
    case authenticate(RouterInput<T>)
    case reauthenticate(RouterInput<T>)
    case switchToken(RouterInput<T>)
    case logout(RouterInput<T>)
    
    var authHeaders: [String : String] {
        switch self {
        case .authenticate(let input), .reauthenticate(let input), .switchToken(let input), .logout(let input):
            return input.headers ?? [String:String]()
        }
    }
    
    private var method: YAPHTTPMethod {
        switch self {
        case .authenticate, .reauthenticate, .switchToken, .logout:
            return .post
        }
    }
    
    private var path: String {
        switch self {
        case .authenticate:
            return "/auth/oauth/oidc/login-token"
        case .reauthenticate:
            return "/auth/oauth/oidc/token"
        case .switchToken:
            return "/auth/oauth/oidc/switch-profile"
        case .logout:
            return "/auth/oauth/oidc/logout"
        }
    }
    
    private var input: RouterInput<T>? {
        switch self {
        case .authenticate(let input):
            return input
        case .reauthenticate(let input):
            return input
        case .switchToken(let input):
            return input
        case .logout(let input):
            return input
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        return try urlRequest(path: path, method: method, input: input)
    }
}
