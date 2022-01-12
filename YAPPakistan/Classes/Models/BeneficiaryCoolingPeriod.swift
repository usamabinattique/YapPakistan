//
//  BeneficiaryCoolingPeriod.swift
//  YAPPakistan
//
//  Created by Umair  on 11/01/2022.
//

import Foundation

public struct BeneficiaryCoolingPeriod {
    public let coolingPeriodDuration: TimeInterval
    public let timePassed: TimeInterval
    public let maxAllowedAmount: Double
    public let consumedAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case coolingPeriodDuration = "coolingPeriodDuration"
        case timePassed = "difference"
        case maxAllowedAmount = "maxAllowedCoolingPeriodAmount"
        case consumedAmount = "consumedAmount"
    }
    
    public var remainingLimit: Double { maxAllowedAmount - consumedAmount < 0 ? 0 : maxAllowedAmount - consumedAmount }
    
    public var isCoolingPeriodOver: Bool { (coolingPeriodDuration * 3600) <= timePassed }
    
    public static var mock = BeneficiaryCoolingPeriod(coolingPeriodDuration: 0, timePassed: 0, maxAllowedAmount: 0, consumedAmount: 0)
}

extension BeneficiaryCoolingPeriod: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BeneficiaryCoolingPeriod.CodingKeys.self)
        self.coolingPeriodDuration = (Double((try? container.decode(String?.self, forKey: .coolingPeriodDuration)) ?? "0") ?? 0)
        self.timePassed = (try? container.decode(Double?.self, forKey: .timePassed)) ?? 0
        self.maxAllowedAmount = Double((try? container.decode(String?.self, forKey: .maxAllowedAmount)) ?? "0") ?? 0
        self.consumedAmount = (try? container.decode(Double?.self, forKey: .consumedAmount)) ?? 0
    }
}
