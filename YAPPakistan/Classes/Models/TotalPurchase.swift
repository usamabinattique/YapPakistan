//
//  TotalPurchase.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 17/03/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation


public struct TotalPurchase: Codable {
    public let txnCount:Int
    public let avgSpendAmount: Double
    public let totalSpendAmount: Double
    
}

// MARK: - Mocked extension
extension TotalPurchase {
    public static var mocked: TotalPurchase {
        return TotalPurchase(txnCount: 4, avgSpendAmount: 99, totalSpendAmount: 144.4)
    }

}
