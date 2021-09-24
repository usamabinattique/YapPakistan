//
//  DefaultFeatureFlagProvider.swift
//  YAPPakistan_Example
//
//  Created by Umer on 24/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

final class DefaultFeatureFlagProvider: FeatureFlagProvider {
    private let jsonURL: URL
    private var flags: [FeatureFlag] = []

    init(jsonUrl: URL) {
        if let data = try? Data(contentsOf: jsonUrl),
           let result = try? JSONDecoder().decode(FeatureFlagResponse.self, from: data) {
            self.flags = result.features
        }
        self.jsonURL = jsonUrl
    }

    public func isFeatureEnabled(_ feature: String) -> Bool {
        if let flag = flags.first(where: { $0.key == feature }) {
            return flag.value
        }
        return false
    }
}
