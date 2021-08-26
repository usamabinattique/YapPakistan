//
//  SignUpOTPRequest.swift
//  YAPPakistan
//
//  Created by Tayyab on 26/08/2021.
//

import Foundation

struct SignUpOTPRequest: Codable {
    var countryCode: String
    var mobileNo: String
    var accountType: String
}
