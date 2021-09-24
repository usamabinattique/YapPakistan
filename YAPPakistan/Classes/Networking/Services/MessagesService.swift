//
//  MessagesService.swift
//  YAPPakistan
//
//  Created by Tayyab on 26/08/2021.
//

import Foundation
import RxSwift

public protocol MessageServiceType: AnyObject {
    func signUpOTP<T: Codable>(countryCode: String, mobileNo: String, accountType: String) -> Observable<T>
    func resendOTP<T: Codable>(countryCode: String, mobileNo: String, accountType: String) -> Observable<T>
    func verifyOTP<T: Codable>(countryCode: String, mobileNo: String, otp: String) -> Observable<T>
    func generateOTP<T>(action: String, mobileNumber: String?) -> RxSwift.Observable<T> where T : Decodable, T : Encodable
}

public class MessagesService: BaseService, MessageServiceType {
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
    
    public func generateOTP<T: Codable>(action: String, mobileNumber: String?) -> Observable<T> {

        var pathVariables: [String]? = nil
        let body = GenerateOTPRequest(action: action)
        if let mobileNumber = mobileNumber {
            pathVariables = [mobileNumber]
        }
        let route = APIEndpoint(.post, apiConfig.messagesURL, "/api/otp/sign-up/verify", pathVariables: pathVariables, body:body, headers:authorizationProvider.authorizationHeaders)
        return self.request(apiClient: apiClient, route: route)
    }
}
