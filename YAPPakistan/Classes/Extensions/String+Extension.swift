//
//  String+Extension.swift
//  YAPPakistan
//
//  Created by Umer on 07/09/2021.
//

import Foundation

public extension String {
    var localized: String {
        #if DEBUG
            return Bundle.yapPakistan.localizedString(forKey: self, value: "\(self)", table: nil)
        #else
            return Bundle.yapPakistan.localizedString(forKey: self, value: nil, table: nil)
        #endif
    }
}

public extension String {
    func getSuperScript(superScript: String)-> NSMutableAttributedString {
        let font:UIFont? =  .small //UIFont.appFont(forTextStyle: .small)
        let fontSuper:UIFont? = .nano //UIFont.appFont(forTextStyle: .nano)
        let date = self
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(date)\(superScript)", attributes: [.font:font!])
        attString.setAttributes([.font:fontSuper!,.baselineOffset:7], range: NSRange(location:date.count,length:superScript.count))
        
        return attString
    }
}

public extension String {
    
    var getCommaSeperatedTwoDecimalValue: NSMutableAttributedString {
        
        let balanceValue = Double(self)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        let formattedNumber = numberFormatter.string(from: NSNumber(value:balanceValue ?? 0.0)) ?? ""
        return NSMutableAttributedString(string: formattedNumber)
    }
}
