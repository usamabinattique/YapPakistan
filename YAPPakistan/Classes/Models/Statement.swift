//
//  Statement.swift
//  YAPPakistan
//
//  Created by Umair  on 29/04/2022.
//

import Foundation

fileprivate var statementDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}

public struct Statement: Codable {
    let month: String?
    let year: String?
    let url: String
    let startDate: String?
    let endDate: String?
    
    enum CodingKeys: String, CodingKey {
        case month = "month"
        case year = "year"
        case url = "statementURL"
        case startDate = "toDate"
        case endDate = "fromDate"
    }
}

// MARK: - Mocked extension
extension Statement {
    public static var mocked: Statement {
        return Statement(month: "05", year: "2020", url: "", startDate: "", endDate: "")
    }

}

extension Statement {
    var date: Date {
        statementDateFormatter.date(from: [month ?? "", year ?? ""].joined(separator: " ")) ?? Date()
    }
}

