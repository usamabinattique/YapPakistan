//
//  EmailStatementRequest.swift
//  YAPPakistan
//
//  Created by Umair  on 11/05/2022.
//

import Foundation

struct EmailStatementRequest: Codable {
    let fileUrl: String
    let month: String
    let year: String
    let statementType: String
    let cardType: String?
}
