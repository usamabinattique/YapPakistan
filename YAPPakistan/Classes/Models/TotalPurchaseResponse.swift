//
//  TotalPurchaseResponse.swift
//  YAPPakistan
//
//  Created by Awais on 24/05/2022.
//

// MARK: - Total Product Purchase Model
struct TotalPurchaseResponse: Codable {
    let creationDate, updatedDate, title, totalAmount: String
    let txnType, currency: String
}
