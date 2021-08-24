//
//  AuthenticationManager.swift
//  YAP
//
//  Created by Muhammad Hassan on 23/01/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

var authenticationBundle: Bundle {
    return Bundle(for: AuthenticationManager.self)
}

public class AuthenticationManager {
//    public static let shared = AuthenticationManager()
//    private let authenticationService: AuthenticationService
//    private let xsrfService: XSRFService
//    private let disposeBag: DisposeBag
//    
//    var xsrf: String? {
//        return HTTPCookieStorage.shared.cookies?.filter { $0.name == "XSRF-TOKEN" }.first?.value
//    }
//    
//    private(set) var jwt: String? {
//        didSet {
//            trimmedJWT = jwt == nil ? nil : jwt?.components(separatedBy: " ").last
//        }
//    }
//    
//    private(set) var trimmedJWT: String?
//    
//    var xsrfCookie: HTTPCookie? {
//        guard let token = xsrf else { return nil }
//        return HTTPCookie(properties: [HTTPCookiePropertyKey.name: "XSRF-TOKEN",
//                                       HTTPCookiePropertyKey.value: token])
//    }
//    
//    public var authorizationHeaders: [String: String] {
//        var headers: [String: String] = [:]
//        if let xsrf = xsrf {
//            headers["X-XSRF-TOKEN"] = xsrf
//            headers["Cookie"] = "XSRF-TOKEN=\(xsrf)"
//        }
//        
//        if let jwt = jwt {
//            headers["Authorization"] = "Bearer \(jwt)"
//        }
//        
//        return headers
//    }
//    
//    private init() {
//        authenticationService = AuthenticationService( xsrfToken: "dsadadd")
//        xsrfService = XSRFService()
//        disposeBag = DisposeBag()
//    }
//    
//    public func setJWT(_ jwt: String) {
//        self.jwt = jwt
//    }
//    
//    public func clearJWT() {
//        jwt = nil
//    }
//    
//    public func getJWT() -> String? {
//        return trimmedJWT
//    }
//    
//    public func getXSRFToken() -> Observable<Void> {
//        return xsrfService.fetchXSRFToken().map { _ in () }
//    }
//    
//    public func refreshJWT() -> Observable<[String: String]> {
//        return authenticationService.reauthenticate(token: jwt ?? "").catchError({ error -> Observable<[String: String]> in
//            NotificationCenter.default.post(name: Notification.Name("authenticationRequire"), object: nil)
//            throw error
//        })
//            .do(onNext: { token in
//                if let jwt = token["id_token"] { self.setJWT(jwt) }
//            })
//    }
//    
//    public func logout<T: Codable>(deviceUUID: String) -> Observable<T> {
//        return authenticationService.logout(deviceUUID: deviceUUID)
//    }
//    
//    public func authenticate<T: Codable>(username: String, password: String, deviceId: String) -> Observable<T> {
//        return authenticationService.authenticate(username: username, password: password, deviceId: deviceId)
//    }
//    
//    public func switchToken<T: Codable>(accountUUID: String) -> Observable<T> {
//        return authenticationService.switchToken(uuid: accountUUID)
//    }
}
