//
//  EmailStatement.swift
//  YAPPakistan
//
//  Created by Umair  on 29/04/2022.
//

import Foundation

public struct EmailStatement: WebContentType {

    let url: URL?
    let month: String?
    let year: String?
    let statementType: String?
    let cardType: String?
}
