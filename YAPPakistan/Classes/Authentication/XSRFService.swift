//
//  XSRFService.swift
//  YAP
//
//  Created by Hussaan S on 05/03/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import Alamofire

public protocol XSRFServiceType {
    func fetchXSRFToken() -> Observable<Bool>
}

public class XSRFService: XSRFServiceType  {
    private let apiConfig: APIConfiguration
    private let apiClient: APIClient

    public init(apiConfig: APIConfiguration, apiClient: APIClient) {
        self.apiConfig = apiConfig
        self.apiClient = apiClient
    }

    func request(apiClient: APIClient, route: YAPURLRequestConvertible) -> Observable<Bool> {
        let route = APIEndpoint<String>(.get, apiConfig.authURL, "/login")
        let response = apiClient.request(route: route)
        return response.flatMap { apiResponse -> Observable<Bool> in
            return Observable.create { observer in
                do {
                    try self.validateXSRFResponse(apiResponse)
                    observer.onNext(true)
                } catch let error {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
    }

    func upload<T>(apiClient: APIClient,
                   documents: [DocumentDataConvertible],
                   route: YAPURLRequestConvertible,
                   progressObserver: AnyObserver<Progress>) -> Observable<Event<T>> where T: Decodable, T: Encodable {
        return Observable.never()
    }

    public func fetchXSRFToken() -> Observable<Bool> {
        let route = APIEndpoint<String>(.get, apiConfig.authURL, "/login")
        return request(apiClient: apiClient, route: route)
    }

    func validateXSRFResponse(_ response: APIResponseConvertible) throws {
        switch response.code {
        case 200 ... 299:
            return
        case 400 ... 499:
            throw WebClientError.serverError(response.code, "No XSRF found.")
        case -1009:
            throw WebClientError.noInternet
        case -1001:
            throw WebClientError.requestTimedOut
        default:
            throw (NetworkReachabilityManager()?.isReachable ?? true) ?
            WebClientError.unknown : WebClientError.noInternet
        }
    }
}
