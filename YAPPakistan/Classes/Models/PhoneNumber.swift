//
//  PhoneNumber.swift
//  OnBoarding
//
//  Created by Wajahat Hassan on 06/12/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

struct PhoneNumber {
    private(set) var number: String?
    private(set) var countryCode: String?
    private(set) var readableCountryCode: String?
    private var pkDialCode: String { "0092" }
    private var pkReadableDialCode: String { "+92" }
    
//    public var formattedValue: String? {
//        didSet {
//            var components = formattedValue?.components(separatedBy: " ")
//            readableCountryCode = components?.first
//            countryCode = components?.first?.replacingOccurrences(of: "+", with: "00")
//            components?.removeFirst()
//            number = components?.joined()
//            number = number?.replacingOccurrences(of: "-", with: "")
//
//        }
//    }

    public var serverFormattedValue: String? {
        return (countryCode ?? "") + (number ?? "")
    }
    
    public var displayFormattedValue: String? {
        return (readableCountryCode ?? "") + " " + (number ?? "")
    }

    public init(formattedValue: String?) {
        //self.formattedValue = formattedValue

            // var components = formattedValue?.components(separatedBy: " ")
        guard var valueString = formattedValue else { return }
        let isCode = valueString.contains(pkDialCode)
        let isReadableCode = valueString.contains(pkReadableDialCode)
        guard (isCode || isReadableCode) == true else { return }
        if isCode {
            countryCode = String(valueString.prefix(pkDialCode.length))
            valueString = valueString.removingPrefix(pkDialCode)
            readableCountryCode = countryCode?.replacingOccurrences(of: "00", with: "+") }
        else {
            readableCountryCode = String(valueString.prefix(pkReadableDialCode.length))
            valueString = valueString.removingPrefix(pkReadableDialCode)
            countryCode = readableCountryCode?.replacingOccurrences(of: "+", with: "00")
        }
        number = valueString
        number = number?.replacingOccurrences(of: "-", with: "")
    }
}
