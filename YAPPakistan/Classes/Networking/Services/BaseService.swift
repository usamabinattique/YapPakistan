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
import Alamofire

public class BaseService: Service {
    // MARK: PROPERTIES
    /// Private
    private let disposeBag = DisposeBag()
    /// Internal
    let apiClient: APIClient
    let apiConfig: APIConfiguration
    let authorizationProvider: ServiceAuthorizationProviderType
    
    // MARK: INITIALIZER
    public init(apiClient: APIClient = WebClient(),
                apiConfig: APIConfiguration,
                authorizationProvider: ServiceAuthorizationProviderType) {
        self.apiClient = apiClient
        self.apiConfig = apiConfig
        self.authorizationProvider = authorizationProvider
    }
    
    private var serverReadableDateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }
    
    public func request<T: Codable>(apiClient: APIClient, route: YAPURLRequestConvertible) -> Observable<T> {
        return apiClient.request(route: route)
            .map { apiResonse -> APIResponseConvertible in
                guard 200...299 ~= apiResonse.code else {
                    throw NetworkErrorHandler.mapError(apiResonse.code, data: apiResonse.data)
                }
                return apiResonse
            }.retry { errorObservable -> Observable<Void> in
                
                errorObservable.map { error -> Void in
                    if case NetworkErrors.authError = error {
                        let notification = Notification(name: Notification.Name(rawValue: "authentication_required"))
                        NotificationCenter.default.post(notification)
                    }
                    throw error
                }
            }
            .map { [unowned self] apiResponse -> T in
                do {
                    let object: Response<T> = try self.decode(data: apiResponse.data)
                    return object.result
                } catch let error {
                    throw error
                }
            }
    }
    
    public func upload<T>(apiClient: APIClient,
                          documents: [DocumentDataConvertible],
                          route: YAPURLRequestConvertible,
                          progressObserver: AnyObserver<Progress>?,
                          otherFormValues formValues: [String: String]) -> Observable<T> where T: Decodable, T: Encodable {
        return apiClient.upload(documents: documents, route: route, progressObserver: progressObserver, otherFormValues: formValues).map { apiResponse -> APIResponseConvertible in
            guard 200...299 ~= apiResponse.code else {
                throw NetworkErrorHandler.mapError(apiResponse.code, data: apiResponse.data)
            }
            return apiResponse
        }
        .retry { errorObservable -> Observable<Void> in
            errorObservable.map { error -> Bool in
                if case NetworkErrors.authError = error { return true }
                throw error
            }.flatMap { _ in
                Observable.of(Notification(name: Notification.Name(rawValue: "authentication_required"))).do(onNext: { notification in NotificationCenter.default.post(notification)}).map { _ in  }
            }
        }
        .map { apiResponse -> T in
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
