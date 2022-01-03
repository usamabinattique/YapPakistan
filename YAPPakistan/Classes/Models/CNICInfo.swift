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

    init() {
        self.name = "Sarmad Abbas"
        self.gender = "M"
        self.dob = "1991-09-05"
        self.issueDate = "2020-09-05"
        self.expiryDate = "2027-09-05"
        self.residentialAddress = "SALAM PURA LAHORE"
    }
}
