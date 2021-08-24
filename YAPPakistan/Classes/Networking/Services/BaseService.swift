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

struct PostRequest: Codable {
    var param1: String
    var param2: String
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
