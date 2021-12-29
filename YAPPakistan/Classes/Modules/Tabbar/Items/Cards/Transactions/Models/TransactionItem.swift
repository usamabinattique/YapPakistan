//
//  Transaction.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 27/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

struct TransactionItem: Codable {
    let vendor: String
    let type: TransactionType
    let imageUrl: String
    let time: String
    let category: String
    let amount: String
    let currency: String
}
