//
//  TransactionBarCategoriesResponse.swift
//  YAPPakistan
//
//  Created by Yasir on 13/04/2022.
//

import Foundation

public struct TransactionBarCategoriesResponse: Codable {
    public let monthData: [MonthData]
}

// MARK: - MonthDatum
public struct MonthData: Codable {
    public let date: String
    public let categories: [Category]
}

// MARK: - Category
public struct Category: Codable {
    public let title: String
    public let txnCount: Int
    public let totalSpending, totalSpendingInPercentage: Double
    public let logoURL: String
    public let yapCategoryID: Int
    public let date: String
    public let categoryWisePercentage: Double
    public let noOfCategories: Int
    public let categoryColor: String

    enum CodingKeys: String, CodingKey {
        case title, txnCount, totalSpending, totalSpendingInPercentage
        case logoURL = "logoUrl"
        case yapCategoryID = "yapCategoryId"
        case categoryColor,date, categoryWisePercentage, noOfCategories
    }
}
