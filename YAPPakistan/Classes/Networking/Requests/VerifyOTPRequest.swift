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
