//
//  TransactionResponse.swift
//  Networking
//
//  Created by Wajahat Hassan on 17/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public struct AddRemoveFundsResponse: Codable {
    public let transactionId: String
    public let balance: String
}
