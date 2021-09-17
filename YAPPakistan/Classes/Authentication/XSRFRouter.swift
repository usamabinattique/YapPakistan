//
//  XSRFRouter.swift
//  Authentication
//
//  Created by Hussaan S on 04/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

enum XSRFRouter: YAPURLRequestConvertible {
    case xsrf

    private var path: String {
        switch self {
        case .xsrf:
            return "/auth/login"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = BaseURL.appendingPathComponent(self.path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = YAPHTTPMethod.get.rawValue
        return urlRequest
    }
}
