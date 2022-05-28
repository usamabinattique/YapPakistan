//
//  TapixTransactionCategory.swift
//  YAPKit
//
//  Created by Muhammad Hassan on 20/04/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation

struct TapixTransactionCategory: Codable {
    let id: Int
    var name: String
    var iconUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "category"
        case iconUrl = "categoryIcon"
    }
    
    var isGeneral: Bool {
        name.lowercased() == "general"
    }
}

extension TapixTransactionCategory {
    init(name: String, iconUrl: String?) {
        id = 0
        self.name = name
        self.iconUrl = iconUrl
    }
}

extension TapixTransactionCategory: Equatable {
    static func == (lhs: TapixTransactionCategory, rhs: TapixTransactionCategory) -> Bool {
        lhs.name == rhs.name
    }
}

//extension TapixTransactionCategory {
//    static var mockCategories: [TapixTransactionCategory] {
//        [
//            TapixTransactionCategory(id: 0, name: "Groceries", iconUrl: nil),
//            TapixTransactionCategory(id: 1, name: "Transport", iconUrl: nil),
//            TapixTransactionCategory(id: 2, name: "Eating out", iconUrl: nil),
//            TapixTransactionCategory(id: 3, name: "Kids", iconUrl: nil),
//            TapixTransactionCategory(id: 4, name: "Shopping", iconUrl: nil),
//            TapixTransactionCategory(id: 5, name: "Personal", iconUrl: nil),
//            TapixTransactionCategory(id: 6, name: "Travel", iconUrl: nil),
//            TapixTransactionCategory(id: 7, name: "Entertainment", iconUrl: nil),
//            TapixTransactionCategory(id: 8, name: "Service & utilities", iconUrl: nil),
//            TapixTransactionCategory(id: 9, name: "Health", iconUrl: nil)
//        ]
//    }
//}
