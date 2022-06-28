//
//  CNICOCR.swift
//  YAPPakistan
//
//  Created by Tayyab on 28/09/2021.
//

import Foundation

// swiftlint:disable identifier_name

public struct CNICOCR: Codable {
    private var _cnicNumber: String
    private var _issueDate: String
    var guardianName: String?

    enum CodingKeys: String, CodingKey {
        case _cnicNumber = "cnic_number"
        case _issueDate = "issue_date"
        case guardianName = "guardian_name"
    }
}

extension CNICOCR {
    var issueDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyy"

        return formatter.date(from: _issueDate)
    }

    var cnicNumber: String {
        let cnic = _cnicNumber
        let stringOut = "\(cnic.prefix(5))-\(cnic.dropFirst(5).prefix(7))-\(cnic.last!)"
        return stringOut
    }
}
