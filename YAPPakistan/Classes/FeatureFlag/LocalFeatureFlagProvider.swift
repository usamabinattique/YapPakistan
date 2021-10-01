//
//  LocalFeatureFlagProvider.swift
//  YAPPakistan_Example
//
//  Created by Umer on 23/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

final class LocalFeatureFlagProvider: FeatureFlagProvider {
    let databaseHandler: FeatureFlagDatabase

    init(databaseHandler: FeatureFlagDatabase) {
        self.databaseHandler = databaseHandler
    }

    public func isFeatureEnabled(_ feature: String) -> Bool {
        if let flag = databaseHandler.readFeatureFlags()?.first(where: { $0.key == feature }) {
            return flag.value
        }
        return false
    }
}
