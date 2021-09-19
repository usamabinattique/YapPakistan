//
//  APIEndpoint.swift
//  YAPPakistan
//
//  Created by Tayyab on 24/08/2021.
//

import Foundation

struct APIEndpoint<Body: Codable>: Convertible, YAPURLRequestConvertible {
    var method: YAPHTTPMethod
    var url: URL
    var path: String
    var pathVariables: [String]?
    var query: [String: String]?
    var requestType: RequestType
    var body: Body?
    var headers: [String: String]

    init(_ method: YAPHTTPMethod, _ url: URL, _ path: String, pathVariables: [String]? = nil,
         query: [String: String]? = nil, requestType: RequestType = .json, body: Body? = nil,
         headers: [String: String] = [:]) {
        self.method = method
        self.url = url
        self.path = path
        self.pathVariables = pathVariables
        self.query = query
        self.requestType = requestType
        self.body = body
        self.headers = headers
    }

    var authHeaders: [String: String] {
        return headers
    }

    func asURLRequest() throws -> URLRequest {
        return try urlRequest(with: url, path: path, method: method, requestType: requestType,
                              input: (body: body, query: query, pathVariables: pathVariables, headers: headers))
    }
}
