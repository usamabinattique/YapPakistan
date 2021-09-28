//
//  RemoteFeatureFlagLoader.swift
//  YAPPakistan_Example
//
//  Created by Umer on 23/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation


final class RemoteFeatureFlagProvider: FeatureFlagProvider {
    let databaseHandler: FeatureFlagDatabase
    init(databaseHandler: FeatureFlagDatabase) {
        self.databaseHandler = databaseHandler
    }

    var isFeatureFlagsAvailable: Bool {
        if let flags = databaseHandler.readFeatureFlags() {
            return flags.isEmpty
        }
        return false
    }

    private func fetchFeatureFlags() {
        
    }

    public func isFeatureEnabled(_ feature: String) -> Bool {
        return false
    }
}



