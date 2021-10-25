//
//  CountryListProvider.swift
//  YAPPakistan_Example
//
//  Created by Umer on 04/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

typealias Country = (name: String, code: String, callingCode: String, flagIconImageName: String)
protocol CountryListProviderType {
    func list() -> [Country]
}

class CountryListProvider: CountryListProviderType {
    private let featureFlagProvider: FeatureFlagProvider
    init(featureFlagProvider: FeatureFlagProvider) {
        self.featureFlagProvider = featureFlagProvider
    }
    func list() -> [Country] {
        var countries: [Country] = []
        if featureFlagProvider.isFeatureEnabled(FeatureFlagName.yapPk) {
            let country = (name: "Pakistan", code: "PK", callingCode: "+92 ", flagIconImageName: "PK")
            countries.append(country)
        }
        return countries
    }
}
