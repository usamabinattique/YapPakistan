//
//  Y2YTransactionResponse.swift
//  YAPPakistan
//
//  Created by Umair  on 10/01/2022.
//

import Foundation

public struct Y2YTransactionResponse: Codable {
    let transactionId: String
    let balance: String
    let currency: String
}
