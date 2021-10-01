//
//  CNICOCR.swift
//  YAPPakistan
//
//  Created by Tayyab on 28/09/2021.
//

import Foundation

struct CNICOCR: Codable {
    var cnicNumber: String
    var issueDate: String

    enum CodingKeys: String, CodingKey {
        case cnicNumber = "cnic_number"
        case issueDate = "issue_date"
    }
}
