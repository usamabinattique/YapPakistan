//
//  MessagesService.swift
//  YAPPakistan
//
//  Created by Tayyab on 26/08/2021.
//

import Foundation
import RxSwift

public protocol MessagesServiceType: AnyObject {
    func signUpOTP<T: Codable>(countryCode: String, mobileNo: String, accountType: String) -> Observable<T>
    func resendOTP<T: Codable>(countryCode: String, mobileNo: String, accountType: String) -> Observable<T>
    func verifyOTP<T: Codable>(countryCode: String, mobileNo: String, otp: String) -> Observable<T>
    func generateOTP<T>(action: String, mobileNumber: String?) -> RxSwift.Observable<T> where T : Decodable, T : Encodable
    func generateForgotOTP<T: Codable>(username: String) -> Observable<T>
    func generateChangeEmailOTP<T: Codable>(action: String, mobilNumber: String?) -> Observable<T>
    func verifyForgotOTP<T: Codable>(username: String, otp: String) -> Observable<T>
    func generateOTP<T: Codable>(action: String) -> Observable<T>
    func verifyOTP<T: Codable>(action: String, otp: String, mobileNumber: String) -> Observable<T>
    func getHelplineNumber<T: Codable>() -> Observable<T>
}

public class MessagesService: BaseService, MessagesServiceType {
    
    
    
    public func signUpOTP<T: Codable>(countryCode: String, mobileNo: String, accountType: String = "B2C_ACCOUNT") -> Observable<T> {
        let body = SignUpOTPRequest(countryCode: countryCode, mobileNo: mobileNo, accountType: accountType)
        let route = APIEndpoint(.post, apiConfig.messagesURL, "/api/otp/sign-up/mobile-no", body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func resendOTP<T: Codable>(countryCode: String, mobileNo: String, accountType: String = "B2C_ACCOUNT") -> Observable<T> {
        let body = SignUpOTPRequest(countryCode: countryCode, mobileNo: mobileNo, accountType: accountType)
        let route = APIEndpoint(.post, apiConfig.messagesURL, "/api/otp/sign-up/mobile-no", body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func verifyOTP<T: Codable>(countryCode: String, mobileNo: String, otp: String) -> Observable<T> {
        let body = VerifyOTPRequest(countryCode: countryCode, mobileNo: mobileNo, otp: otp)
        let route = APIEndpoint(.put, apiConfig.messagesURL, "/api/otp/sign-up/verify", body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func generateChangeEmailOTP<T: Codable>(action: String, mobilNumber mobileNumber: String?) -> Observable<T> {

        var pathVariables: [String]? = nil
        let body = GenerateOTPRequest(action: action)
        if let mobileNumber = mobileNumber {
            pathVariables = [mobileNumber]
        }
        let route = APIEndpoint(.post, apiConfig.messagesURL, "/api/otp", pathVariables: pathVariables, body:body, headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: apiClient, route: route)
    }
    
    public func generateOTP<T: Codable>(action: String, mobileNumber: String?) -> Observable<T> {

        var pathVariables: [String]? = nil
        let body = GenerateOTPRequest(action: action)
        if let mobileNumber = mobileNumber {
            pathVariables = [mobileNumber]
        }
        let route = APIEndpoint(.post, apiConfig.messagesURL, "/api/otp/sign-up/verify", pathVariables: pathVariables, body:body, headers:authorizationProvider.authorizationHeaders)
        return self.request(apiClient: apiClient, route: route)
    }

    
    public func generateForgotOTP<T: Codable>(username: String) -> Observable<T> {
        let request = [
            "destination": username,
            "emailOTP": "false"
        ]

        let route = APIEndpoint(.post, apiConfig.messagesURL, "/api/otp/action/forgot-password",
                                body: request, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func verifyForgotOTP<T: Codable>(username: String, otp: String) -> Observable<T> {
        let request = [
            "otp": otp,
            "destination": username,
            "emailOTP": "false"
        ]

        let route = APIEndpoint(.put, apiConfig.messagesURL, "/api/otp/action/forgot-password",
                                body: request, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func generateOTP<T: Codable>(action: String) -> Observable<T> {
        //"action": "FORGOT_CARD_PIN"
        let body = [
            "action": action
        ]

        let route = APIEndpoint(.post,
                                apiConfig.messagesURL,
                                "/api/otp",
                                body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func verifyOTP<T: Codable>(action: String, otp: String, mobileNumber: String) -> Observable<T> {
        //"action": "FORGOT_CARD_PIN"
        let body = [
            "action": action,
            "otp": otp
        ]
        
        var pathVariables: [String]? = nil
        pathVariables = [mobileNumber]

        let route = APIEndpoint(.put,
                                apiConfig.messagesURL,
                                "/api/otp",
                                pathVariables: pathVariables, body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func getHelplineNumber<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get,
                                apiConfig.messagesURL,
                                "/api/help-desk",
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
}
