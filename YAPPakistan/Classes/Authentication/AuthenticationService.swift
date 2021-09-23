//
//  AuthenticationService.swift
//  Authentication
//
//  Created by Muhammad Hassan on 20/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

public protocol ServiceAuthorizationProviderType {
    var tokenObserver: AnyObserver<String> { get }
    var authorizationHeaders: [String: String] { get }
}

public protocol AuthenticationServiceType {
    func logout<T: Codable>(deviceUUID: String) -> Observable<T>
    func authenticate<T: Codable>(username: String, password: String, deviceId: String) -> Observable<T>
    func saveProfile<T: Codable>(firstName: String, lastName: String, email: String, companyName: String?,
                                 countryCode: String, phone: String, passcode: String, accountType: String, token: String?) -> Observable<T>
    func reauthenticate<T: Codable>(token: String) -> Observable<T>
}

public class AuthenticationService: AuthBaseService, AuthenticationServiceType {
    private let apiConfig: APIConfiguration
    private let apiClient: APIClient
    private let authorizationProvider: ServiceAuthorizationProviderType

    public init(apiConfig: APIConfiguration,
                apiClient: APIClient,
                authorizationProvider: ServiceAuthorizationProviderType) {
        self.apiConfig = apiConfig
        self.apiClient = apiClient
        self.authorizationProvider = authorizationProvider
    }

    public func reauthenticate<T: Codable>(token: String) -> Observable<T> {
        let params = ["grant_type": "refresh", "id_token": token]
        let route = APIEndpoint(.post, apiConfig.authURL, "/oauth/oidc/token", body: params,
                                headers: authorizationProvider.authorizationHeaders)

        return request(apiClient: apiClient, route: route)
    }

    public func authenticate<T: Codable>(username: String, password: String, deviceId: String) -> Observable<T> {
        let params = ["client_id": username, "client_secret": password, "grant_type": "client_credentials", "device_id": deviceId] //, "isInternalUser":"true"]
        let route = APIEndpoint(.post, apiConfig.authURL, "/oauth/oidc/login-token", body: params,
                                headers: authorizationProvider.authorizationHeaders)

        return request(apiClient: apiClient, route: route)
    }

    public func saveProfile<T: Codable>(firstName: String,
                                        lastName: String,
                                        email: String,
                                        companyName: String?,
                                        countryCode: String, phone: String, passcode: String, accountType: String, token: String?) -> Observable<T> {
        Observable.empty()
    }

    func switchToken<T: Codable>(uuid: String) -> Observable<T> {
        let params = ["account_uuid": uuid]
        let route = APIEndpoint(.post, apiConfig.authURL, "/oauth/oidc/switch-profile", body: params,
                                headers: authorizationProvider.authorizationHeaders)

        return request(apiClient: apiClient, route: route)
    }

    public func logout<T: Codable>(deviceUUID: String) -> Observable<T> {
        let params = ["uuid": deviceUUID]
        let route = APIEndpoint(.post, apiConfig.authURL, "/oauth/oidc/logout", body: params,
                                headers: authorizationProvider.authorizationHeaders)

        return request(apiClient: apiClient, route: route)
    }
}

func decode<T: Codable>(data: Data) throws -> T {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .millisecondsSince1970
    return try decoder.decode(T.self, from: data)
}
