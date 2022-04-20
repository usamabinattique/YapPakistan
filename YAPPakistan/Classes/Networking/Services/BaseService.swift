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
import YAPCore

public class BaseService: Service {
    // MARK: PROPERTIES
    /// Private
    private let disposeBag = DisposeBag()
    /// Internal
    let apiConfig: APIConfiguration
    let apiClient: APIClient
    let authorizationProvider: ServiceAuthorizationProviderType

    // MARK: INITIALIZER
    public init(apiConfig: APIConfiguration,
                apiClient: APIClient,
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
                        print("authentication error found in base services )")
//                        let notification = Notification(name: Notification.Name(rawValue: "authentication_required"))
//                        NotificationCenter.default.post(notification)
//                        let name = Notification.Name.init(.au)
//                        NotificationCenter.default.post(name: name, object: unreadMessagesCount)
                        let name = Notification.Name.init(.authenticationRequired)
                        NotificationCenter.default.post(name: name,object: nil)
                    }
                    throw error
                }
            }
            .map { [unowned self] apiResponse -> T in
                do {
                    let object: Response<T> = try self.decode(data: apiResponse.data)
                    return object.result
                } catch {
                   print("error: ", error)
                   throw error
               }
//                catch let DecodingError.dataCorrupted(context){
//                    print(context)
//                } catch let DecodingError.keyNotFound(key, context) {
//                    print("Key '\(key)' not found:", context.debugDescription)
//                    print("codingPath:", context.codingPath)
//                } catch let DecodingError.valueNotFound(value, context) {
//                    print("Value '\(value)' not found:", context.debugDescription)
//                    print("codingPath:", context.codingPath)
//                } catch let DecodingError.typeMismatch(type, context)  {
//                    print("Type '\(type)' mismatch:", context.debugDescription)
//                    print("codingPath:", context.codingPath)
//                } catch {
//                    print("error: ", error)
//                    throw error
//                }
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
                Observable.of(Notification.Name.init(.authenticationRequired)).do(onNext: { notification in
                    NotificationCenter.default.post(name: notification,object: nil) }).map { _ in }
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
