//
//  CNICInfo.swift
//  YAPPakistan
//
//  Created by Tayyab on 30/09/2021.
//

import Foundation

struct CNICInfo: Codable {
    var name: String
    var gender: String
    var dob: String
    var issueDate: String
    var expiryDate: String
    var residentialAddress: String

    enum CodingKeys: String, CodingKey {
        case name
        case gender
        case dob
        case issueDate
        case expiryDate
        case residentialAddress
    }
}
