//
//  MessagesService.swift
//  YAPPakistan
//
//  Created by Tayyab on 26/08/2021.
//

import Foundation
import RxSwift

public class MessagesService: BaseService {
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
}
