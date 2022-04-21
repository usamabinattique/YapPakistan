//
//  Double+Extensions.swift
//  YAPKit
//
//  Created by Zain on 27/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

extension Double {
    var userReadable: (value: Double, denomination: String) {
        
        if self >= 1000000000000 {
            return (self/1000000000000, "T")
        }
        
        if self >= 1000000000 {
            return (self/1000000000, "B")
        }
        
        if self >= 10000000 {
            return (self/1000000, "M")
        }
        
        return (self, "")
    }
    
    func toString() -> String {
        return String(format: "%.0f", self)
    }
    
    var formattedAmount: String { NumberFormatter.formateAmount(self) }
    
    func formattedAmount(toFractionDigits digits: Int) -> String {
        NumberFormatter.formateAmount(self, fractionDigits: digits)
    }
    
    func rounded(toPlaces decimalPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(decimalPlaces))
        return (self * divisor).rounded() / divisor
    }
    
    func roundedHalfEvenUp(toPlaces decimalPlaces: Int) -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits =  decimalPlaces
        formatter.minimumFractionDigits =  decimalPlaces
        formatter.roundingMode = .halfEven
        if let formtedAmount = formatter.string(from: NSNumber(value: self)) {
            return Double(convertWithLocale: formtedAmount) ?? 0
        }
        return rounded(toPlaces: decimalPlaces)
    }
    
    func withGroupingSeparator() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
    func truncateDecimalsAfter(places : Int)-> Double {
        return Double(Darwin.floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
    
    init?(convertWithLocale string: String) {
        let number = localeNumberFormatter.number(from: string.removingGroupingSeparator()) ?? 0
        self.init(exactly: number)
    }
    
    func twoDecimal()-> String {
        return String(format: "%.2f", self)
    }
}
