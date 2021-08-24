//
//  BaseService.swift
//  Networking
//
//  Created by Muhammad Hassan on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

struct APIEndpoint<Body: Codable>: Convertible, YAPURLRequestConvertible {
    var method: YAPHTTPMethod
    var url: URL
    var path: String
    var pathVariables: [String]?
    var query: [String: String]?
    var requestType: RequestType
    var body: Body?
    var headers: [String: String]
    var authHeaders: [String: String]

    init(_ method: YAPHTTPMethod, _ url: URL, _ path: String, pathVariables: [String]? = nil,
         query: [String : String]? = nil, requestType: RequestType = .json, body: Body? = nil,
         headers: [String: String] = [:], authHeaders: [String : String] = [:]) {
        self.method = method
        self.url = url
        self.path = path
        self.pathVariables = pathVariables
        self.query = query
        self.requestType = requestType
        self.body = body
        self.headers = headers
        self.authHeaders = authHeaders
    }

    func asURLRequest() throws -> URLRequest {
        return try urlRequest(with: url, path: path, method: method, requestType: requestType,
                              input: (body: body, query: query, pathVariables: pathVariables, headers: headers))
    }
}

struct APIConfiguration {
    let baseURL: URL
}

struct PostRequest: Codable {
    var param1: String
    var param2: String
}

class SampleService: BaseService {
    private let apiClient: APIClient
    private let config: APIConfiguration

    init(apiClient: APIClient = WebClient(), config: APIConfiguration) {
        self.apiClient = apiClient
        self.config = config
    }

    func getRequest<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, config.baseURL, "/get",
                                        query: ["lat": "30", "long": "30"])

        return self.request(apiClient: self.apiClient, route: route)
    }

    func postRequest<T: Codable>(param1: String, param2: String) -> Observable<T> {
        let body = PostRequest(param1: param1, param2: param2)
        let route = APIEndpoint(.post, config.baseURL, "/post", body: body)

        return self.request(apiClient: self.apiClient, route: route)
    }
}

public class BaseService: Service {
    
    private var serverReadableDateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }
    
    let disposeBag = DisposeBag()
//    var interceptor: AuthenticationInterceptor = WebClientInterceptor()
    
    public func request<T: Codable>(apiClient: APIClient, route: YAPURLRequestConvertible) -> Observable<T> {

        return apiClient.request(route: route).map { apiResonse -> APIResponseConvertible in
            guard 200...299 ~= apiResonse.code else {
                throw NetworkErrorHandler.mapError(apiResonse.code, data: apiResonse.data)
            }
            return apiResonse
//        }.retryWhen { errorObservable -> Observable<Void> in
//            //TODO: Add this in Auth Interceptor
//            errorObservable.map { error -> Bool in
//                if case NetworkErrors.authError = error { return true }
//                throw error
//            }.flatMap { _ in
//                AuthenticationManager.shared.refreshJWT().map {_ in ()}
//            }
        }.map { [unowned self] apiResponse -> T in
            do {
                let object: Response<T> = try self.decode(data: apiResponse.data)
                return object.result
            } catch let error {
                throw error
            }
        }
    }
    
    public func upload<T>(apiClient: APIClient, documents: [DocumentDataConvertible], route: YAPURLRequestConvertible, progressObserver: AnyObserver<Progress>?, otherFormValues formValues: [String: String]) -> Observable<T> where T: Decodable, T: Encodable {
        return apiClient.upload(documents: documents, route: route, progressObserver: progressObserver, otherFormValues: formValues).map { apiResponse -> APIResponseConvertible in
            guard 200...299 ~= apiResponse.code else {
                throw NetworkErrorHandler.mapError(apiResponse.code, data: apiResponse.data)
            }
            return apiResponse
//        }.retryWhen { errorObservable -> Observable<Void> in
//            //TODO: Add this in Auth Interceptor
//            errorObservable.map { error -> Bool in
//                if case NetworkErrors.authError = error { return true }
//                throw error
//            }.flatMap { _ in
//                AuthenticationManager.shared.refreshJWT().map {_ in ()}
//            }
        }.map { apiResponse -> T in
            do {
                let object: Response<T> = try self.decode(data: apiResponse.data)
                return object.result
            } catch let error {
                throw error
            }
        }
    }
    
    func decode<T: Codable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(serverReadableDateTimeFormatter)
        return try decoder.decode(T.self, from: data)
    }
}
