//
//  VerifyOTPRequest.swift
//  YAPPakistan
//
//  Created by Tayyab on 26/08/2021.
//

import Foundation

struct VerifyOTPRequest: Codable {
    var countryCode: String
    var mobileNo: String
    var otp: String
}

struct GenerateOTPRequest: Codable {
    let action: String
    
    enum CodingKeys: String, CodingKey {
        case action
    }
}

struct CreateForgotPasswordOTPRequest: Codable {
    let emailOTP: Bool
    let destination: String
}

struct VerifyForgotPasswordOTPRequest: Codable {
    let otp: String
    let emailOTP: Bool
    let destination: String
}
