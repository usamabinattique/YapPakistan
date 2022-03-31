//
//  BankTransferResponse.swift
//  YAPPakistan
//
//  Created by Yasir on 30/03/2022.
//

import Foundation

public struct BankTransferResponse: Codable {
    
    public let transactionId: String
    public let currency: String
    public let accountNo: String
    public let bankLogoURL: String?
    public let bankName: String
    public let amountTransferred: String
    public let date: String
}

public extension BankTransferResponse {
    static var mock: BankTransferResponse {
        BankTransferResponse(transactionId: "01", currency: "PKR", accountNo: "12343243423424", bankLogoURL: nil, bankName: "ABC", amountTransferred: "0", date: "2022-03-08T06:33:55.533292496")
    }
}
