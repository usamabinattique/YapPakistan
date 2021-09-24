//
//  CustomersService.swift
//  YAPPakistan
//
//  Created by Tayyab on 26/08/2021.
//

import Foundation
import RxSwift

public protocol CustomerServiceType {
    func signUpEmail<T: Codable>( email: String,
                                  otpToken: String,
                                  accountType: String ) -> Observable<T>

    func saveProfile<T: Codable>( countryCode: String,
                                  mobileNo: String,
                                  passcode: String,
                                  firstName: String,
                                  lastName: String,
                                  email: String,
                                  token: String,
                                  whiteListed: Bool,
                                  accountType: String ) -> Observable<T>

    func saveDemographics<T: Codable>( action: String,
                                       deviceId: String,
                                       deviceName: String,
                                       deviceModel: String,
                                       osType: String,
                                       osVersion: String,
                                       token: String?) -> Observable<T>

    func fetchAccounts<T: Codable>() -> Observable<T>

    func assignIBAN<T: Codable>(countryCode: String, mobileNo: String) -> Observable<T>

    func saveInvite<T: Codable>( inviterCustomerId: String,
                                 referralDate: String) -> Observable<T>

    func fetchRanking<T: Codable>() -> Observable<T>

    func saveReferralInvitation<T: Codable>(inviterCustomerId: String,
                                            referralDate: String) -> Observable<T>

    func verifyUser<T: Codable>(username: String) -> Observable<T>
    
    func verifyPasscode<T: Codable>(passcode: String) -> Observable<T>
    
    func generateLoginOTP<T: Codable>(username: String,
                                      passcode: String,
                                      deviceID: String) -> Observable<T>
    
    func verifyLoginOTP<T: Codable>(username: String,
                                           passcode: String,
                                           deviceID: String,
                                           otp: String) -> Observable<T>
}

    
public class CustomersService: BaseService, CustomerServiceType {
    public func signUpEmail<T: Codable>(email: String, otpToken: String,
                                        accountType: String = "B2C_ACCOUNT") -> Observable<T> {
        let body = SignUpEmailRequest(email: email, accountType: accountType, token: otpToken)
        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/sign-up/email", body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func saveProfile<T: Codable>(countryCode: String, mobileNo: String, passcode: String,
                                        firstName: String, lastName: String, email: String,
                                        token: String, whiteListed: Bool,
                                        accountType: String = "B2C_ACCOUNT") -> Observable<T> {
        let body = SaveProfileRequest(countryCode: countryCode, mobileNo: mobileNo,
                                      passcode: passcode, firstName: firstName, lastName: lastName,
                                      email: email, token: token, whiteListed: whiteListed,
                                      accountType: accountType)
        let route = APIEndpoint(.post,
                                apiConfig.customersURL, "/api/profile",
                                body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func saveDemographics<T: Codable>(action: String, deviceId: String, deviceName: String,
                                             deviceModel: String, osType: String, osVersion: String,
                                             token: String?) -> Observable<T> {
        let body = SaveDemographicsRequest(action: action, deviceId: deviceId,
                                           deviceName: deviceName, deviceModel: deviceModel,
                                           osType: osType, osVersion: osVersion, token: token)
        let route = APIEndpoint(.put, apiConfig.customersURL, "/api/demographics/", body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func fetchAccounts<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/accounts", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func assignIBAN<T: Codable>(countryCode: String, mobileNo: String) -> Observable<T> {
        let body = [
            "countryCode": countryCode,
            "mobileNo": mobileNo
        ]
        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/v2/profile", body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func saveInvite<T: Codable>(inviterCustomerId: String, referralDate: String) -> Observable<T> {
        let body = [
            "inviterCustomerId": inviterCustomerId,
            "referralDate": referralDate
        ]

        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/save-invite", body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func fetchRanking<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/fetch-ranking", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func saveReferralInvitation<T: Codable>(inviterCustomerId: String, referralDate: String) -> Observable<T> {
        let body = [
            "inviterCustomerId": inviterCustomerId,
            "referralDate": referralDate
        ]

        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/save-referral-invitation", body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func verifyUser<T: Codable>(username: String) -> Observable<T> {
        let query = ["username": username]
        
        let route = APIEndpoint<String>(.post, apiConfig.customersURL, "/api/verify-user", query: query, headers: authorizationProvider.authorizationHeaders)
        
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func verifyPasscode<T: Codable>(passcode: String) -> Observable<T> {
        let query = ["passcode": passcode]
        
        let route = APIEndpoint<String>(.post, apiConfig.customersURL, "/api/user/verify-passcode", query: query, headers: authorizationProvider.authorizationHeaders)
        
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func generateLoginOTP<T: Codable>(username: String, passcode: String, deviceID: String) -> Observable<T> {
        let request = [
            "clientId": username,
            "clientSecret": passcode,
            "deviceId": deviceID
        ]

        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/demographics/device-login",
                                body: request, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func verifyLoginOTP<T: Codable>(username: String, passcode: String, deviceID: String, otp: String) -> Observable<T> {
        let body = [
            "clientId": username,
            "clientSecret": passcode,
            "deviceId": deviceID,
            "otp": otp
        ]

        let route = APIEndpoint(.put, apiConfig.customersURL, "/api/demographics/device-login",
                                body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
}
