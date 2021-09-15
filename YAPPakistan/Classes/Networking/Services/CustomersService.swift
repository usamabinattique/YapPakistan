//
//  CustomersService.swift
//  YAPPakistan
//
//  Created by Tayyab on 26/08/2021.
//

import Foundation
import RxSwift

public class CustomersService: BaseService {
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
                                             token: String) -> Observable<T> {
        let body = SaveDemographicsRequest(action: action, deviceId: deviceId,
                                           deviceName: deviceName, deviceModel: deviceModel,
                                           osType: osType, osVersion: osVersion, token: token)
        let route = APIEndpoint(.put, apiConfig.customersURL, "/api/demographics", body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func fetchAccounts<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/accounts", headers: authorizationProvider.authorizationHeaders)

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
}
