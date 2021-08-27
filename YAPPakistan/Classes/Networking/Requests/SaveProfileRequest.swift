//
//  SaveProfileRequest.swift
//  YAPPakistan
//
//  Created by Tayyab on 26/08/2021.
//

import Foundation

/*
{
 "firstName": "post",
 "mobileNo": "5653682692",
 "whiteListed": false,
 "accountType": "B2C_ACCOUNT",
 "email": "postamn1@yap1.co",
 "passcode": "1212",
 "countryCode": "0092",
 "token": "kac9812isnkc",
 "lastName": "man one"
}
*/
struct SaveProfileRequest: Codable {
    var countryCode: String
    var mobileNo: String
    var passcode: String
    var firstName: String
    var lastName: String
    var email: String
    var token: String
    var whiteListed: Bool
    var accountType: String
}
