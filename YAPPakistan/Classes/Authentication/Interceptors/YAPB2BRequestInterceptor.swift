//
//  YAPB2BRequestInterceptor.swift
//  APIClient
//
//  Created by Umer on 18/07/2021.
//  Copyright © 2021 Muhammad Hassan. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import Alamofire


final class YAPB2BRequestInterceptor: Alamofire.RequestInterceptor {
    
    private let authorizationProvider: ServiceAuthorizationProviderType
    init(authorizationProvider: ServiceAuthorizationProviderType) {
        self.authorizationProvider = authorizationProvider
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        /// Set the Authorization header value using the access token.
        for (key, value) in authorizationProvider.authorizationHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            /// The request did not fail due to a 401 Unauthorized response.
            /// Return the original error and don't retry the request.
            return completion(.doNotRetryWithError(error))
        }
        
        guard let jwt = self.authorizationProvider.authorizationHeaders["Authorization"] else {
            // Broadcast notification for App coordinator
            NotificationCenter.default.post(name: Notification.Name("LOGOUT_CURRENT_USER"), object: nil, userInfo: nil)
            return
        }
        
        let authService = AuthenticationService(authorizationProvider: authorizationProvider)
        let result: Observable<[String: String]> = authService.reauthenticate(token: jwt)
        result.catch { error -> Observable<[String : String]> in
            // Broadcast notification for App coordinator
            completion(.doNotRetryWithError(error))
            NotificationCenter.default.post(name: Notification.Name("LOGOUT_CURRENT_USER"), object: nil, userInfo: nil)
            return Observable.of([:])
        }.do(onNext: { tokenDictionary in
            if let jwt = tokenDictionary["id_token"] {
                self.authorizationProvider.tokenObserver.onNext(jwt)
                completion(.retry)
            }
        })
        
    }
}
