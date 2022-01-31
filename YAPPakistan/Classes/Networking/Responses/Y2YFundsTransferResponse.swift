//
//  Y2YFundsTransferResponse.swift
//  YAPPakistan
//
//  Created by Yasir on 26/01/2022.
//

import Foundation

public struct Y2YFundsTransferResponse: Codable {
    
    public let transactionId: String
    public let balance: String
    public let currency: String
    public let contactNumber: String
    public let amountTransferred: String
    public let date: String

    enum CodingKeys: String, CodingKey {
        case transactionId
        case balance
        case currency
        case contactNumber
        case amountTransferred
        case date
    }
}

public extension Y2YFundsTransferResponse {
    static var mock: Y2YFundsTransferResponse {
        Y2YFundsTransferResponse(transactionId: "0", balance: "1", currency: "PKR", contactNumber: "0", amountTransferred: "0.0", date: "\(Date())")
    }
}
