//
//  TransferReason.swift
//  YAPPakistan
//
//  Created by Awais on 21/03/2022.
//

import Foundation
protocol TransferReasonType {
    var title: String { get }
    var isCategory: Bool { get }
}

// MARK: Tranfer reason category

struct TransferReasonCategory {
    let categoryName: String
    let reasons: [TransferReason]
}

extension TransferReasonCategory: TransferReasonType {
    var title: String { categoryName }
    var isCategory: Bool { true }
}

// MARK: Tranfer reason

public struct TransferReason {
    let code: String?
    let text: String
    let cbwsi: Bool?
    let cbwsiFee: Bool?
    let nonChargeable: Bool?
    let category: String?
    
    var isCBWSI: Bool { cbwsi ?? false }
    var isCBWSIFee: Bool { cbwsiFee ?? true }
    var isFeeChargeable: Bool { !(nonChargeable ?? false) }
    
    var isCBWSIApplicable: Bool { isCBWSI && !isCBWSIFee }
}

extension TransferReason: Codable {
    private enum CodingKeys: String, CodingKey {
        case code = "purposeCode"
        case text = "purposeDescription"
        case cbwsi = "cbwsi"
        case cbwsiFee = "cbwsiFee"
        case nonChargeable = "nonChargeable"
        case category = "purposeCategory"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TransferReason.CodingKeys.self)
        self.code = try container.decode(String?.self, forKey: .code)
        self.text = try container.decode(String?.self, forKey: .text) ?? ""
        self.cbwsi = try container.decode(Bool?.self, forKey: .cbwsi)
        self.cbwsiFee = try container.decode(Bool?.self, forKey: .cbwsiFee)
        self.nonChargeable = try container.decode(Bool?.self, forKey: .nonChargeable)
        self.category = try container.decode(String?.self, forKey: .category)
    }
    
    public var isRecurrable: Bool { return code == "TR002" }
}

extension TransferReason: TransferReasonType {
    var title: String { text }
    var isCategory: Bool { false }
}

// MARK: Mocked

extension TransferReason {
    static var mocked: TransferReason {
        TransferReason(code: "mockedTransfer", text: "Mock transfer", cbwsi: true, cbwsiFee: false, nonChargeable: true, category: "mocked")
    }
}

extension TransferReason: Equatable {
    public static func == (lhs: TransferReason, rhs: TransferReason) -> Bool {
        lhs.code == rhs.code
    }
}
