//
//  BaseService.swift
//  Authentication
//
//  Created by Muhammad Hassan on 20/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

public enum AuthenticationError: Error {
    case expiredJWT
    case serverError(Int, String)
    case unknown
}

extension AuthenticationError {
    public var errorDescription: String? {
        switch self {
        case .expiredJWT:
            return "JWT Expired"
        case .serverError(_, let message):
            return message
        case .unknown:
            return "Unknown"            // TODO: add localized error description here
        }
    }
}

struct AuthResponse<T: Codable>: Codable {
    let result: T
    let serverErrors: [ServerError]?
}

extension AuthResponse {
    private enum CodingKeys: String, CodingKey {
        case result = "data"
        case serverErrors = "errors"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decode(T.self, forKey: .result)
        serverErrors = try values.decode([ServerError]?.self, forKey: .serverErrors)
    }
}

public class AuthBaseService {
    
    let disposeBag = DisposeBag()
    
    func request<T: Codable>(apiClient: APIClient, route: YAPURLRequestConvertible) -> Observable<T> {
        return apiClient.request(route: route).map { apiResponse -> T in
            let object: T = try self.validate(response: apiResponse)
            return object
        }
//        response.flatMap { apiResponse -> Observable<T> in
//            return Observable.create { observer in
//                do {
//                    let object: T = try self.validate(response: apiResponse)
//                    observer.onNext(object)
//                } catch let error {
//                    observer.onError(error)
//                }
//                return Disposables.create()
//                }
//            }.bind(to: subject).disposed(by: disposeBag)
//
//        return subject.asObservable()
    }
}

extension AuthBaseService {
    func validate<T: Codable>(response: APIResponseConvertible) throws -> T {
        let code = response.code
        switch code {
        case 200...299:
            return try decode(data: response.data)
        case 400...499:
            let response: Response<T> = try decode(data: response.data)
            guard let errors = response.serverErrors, !errors.isEmpty else { throw AuthenticationError.unknown }
            throw AuthenticationError.serverError(Int(errors.first?.code ?? "") ?? 0, errors.first?.message ?? "")
        default:
            throw AuthenticationError.unknown
        }
    }
}
