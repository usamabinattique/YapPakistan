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
    let senderUUID: String
    let receiverUUID: String
    let amountTransferred: String
    let date: String // 2022-03-10T11:56:10.981551559
    let receiverContactNo: String
    
}

public extension Y2YTransactionResponse {
    
    static var mock: Y2YTransactionResponse {
        Y2YTransactionResponse(transactionId: "afddf", balance: "0.0", currency: "PKR", senderUUID: "abc", receiverUUID: "abc", amountTransferred: "0.0", date: "2022-03-10T11:56:10.981551559", receiverContactNo: "adf")
    }
}
