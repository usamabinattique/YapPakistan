//
//  Bank.swift
//  YAP
//
//  Created by Muhammad Hassan on 28/02/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public struct Bank: Codable {
   public let id: Int
   public let name: String
   public let bankCode: String
   public let swiftCode: String
   public let address: String
}
