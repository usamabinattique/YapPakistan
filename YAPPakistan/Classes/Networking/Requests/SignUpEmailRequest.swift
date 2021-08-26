//
//  SignUpEmailRequest.swift
//  YAPPakistan
//
//  Created by Tayyab on 26/08/2021.
//

import Foundation

struct SignUpEmailRequest: Codable {
    var email: String
    var accountType: String
    var token: String
}
