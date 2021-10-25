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

    public var formattedValue: String? {
        didSet {
            var components = formattedValue?.components(separatedBy: " ")
            readableCountryCode = components?.first
            countryCode = components?.first?.replacingOccurrences(of: "+", with: "00")
            components?.removeFirst()
            number = components?.joined()
            number = number?.replacingOccurrences(of: "-", with: "")
        }
    }

    public var serverFormattedValue: String? {
        return (countryCode ?? "") + (number ?? "")
    }

    public init(formattedValue: String?) {
        self.formattedValue = formattedValue

        var components = formattedValue?.components(separatedBy: " ")
        readableCountryCode = components?.first
        countryCode = components?.first?.replacingOccurrences(of: "+", with: "00")
        components?.removeFirst()
        number = components?.joined()
        number = number?.replacingOccurrences(of: "-", with: "")
    }
}
