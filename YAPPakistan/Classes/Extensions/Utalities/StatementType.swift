//
//  StatementType.swift
//  YAPPakistan
//
//  Created by Umair  on 28/04/2022.
//

import Foundation

public enum StatementType {
    case card
    case account
    case wallet
}

public protocol StatementFetchable {
    var idForStatements: String? { get }
    var statementType: StatementType { get }
}
