//
//  Convertible.swift
//  YAP
//
//  Created by MHS on 27/08/2018.
//  Copyright © 2018 YAP. All rights reserved.
//

import Foundation

public typealias RouterInput<T> = (body: T?, query: [String: String]?, pathVariables: [String]?, headers: [String: String]?)

public enum RequestType: Int {
    case json
    case formData
}

public extension RequestType {
    var requestHeaders: [String: String] {
        var headers = [String: String]()
        switch self {
        case .json:
            headers["Content-Type"] = "application/json"
            headers["Accept"] = "application/json"
        case .formData:
            headers["Content-type"] = "multipart/form-data"
            headers["Accept"] = "application/json"
        }
        return headers
    }
}

public protocol Convertible {

    func urlRequest<T: Codable>(with url: URL, path: String, method: YAPHTTPMethod, requestType: RequestType, input: RouterInput<T>?) throws -> URLRequest

    var authHeaders: [String: String] { get }
}

public extension Convertible {

    func urlRequest<T: Codable>(with url: URL = BaseURL, path: String, method: YAPHTTPMethod, requestType: RequestType = .json, input: RouterInput<T>?) throws -> URLRequest {

        let url = try constructAPIUrl(with: url, path: path, input: input)
        var urlRequest = URLRequest(url: url)

        urlRequest.httpMethod = method.rawValue

        let requestTypeHeaders = requestType.requestHeaders
        for (key, value) in requestTypeHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        for (key, value) in authHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let parameters = input?.body {
            urlRequest.httpBody = Data()
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .millisecondsSince1970
                urlRequest.httpBody = try encoder.encode(parameters)
            } catch {
                throw error
            }
        }

        return urlRequest
    }

    private func constructAPIUrl<T: Codable>(with url: URL, path: String, input: RouterInput<T>?) throws -> URL {

        guard let `input` = input else { return url.appendingPathComponent(path) }

        var constructedURL = url.appendingPathComponent(path)

        if let pathVariables = input.pathVariables {
            for pathVariable in pathVariables {
                constructedURL.appendPathComponent(pathVariable)
            }
        }

        if let query = input.query {
            var components = URLComponents(string: constructedURL.absoluteString)!
            var queryItems = [URLQueryItem]()
            for (key, value) in query {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
            components.queryItems = queryItems
            return components.url!
        }

        return constructedURL
    }
}
