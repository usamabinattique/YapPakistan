//
//  TransferReason.swift
//  YAPPakistan
//
//  Created by Awais on 21/03/2022.
//

import Foundation

public struct TransferReason: Codable {
    let code: String
    let transferReason: String
}
// MARK: Mocked

public extension TransferReason {
    static var mock: TransferReason {
        TransferReason(code: "mocked", transferReason: "mockedTransfer")
    }
}

extension TransferReason: Equatable {
    public static func == (lhs: TransferReason, rhs: TransferReason) -> Bool {
        lhs.code == rhs.code
    }
}
