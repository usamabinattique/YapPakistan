//
//  RemoteFallbackToLocalFeatureFlagProvider.swift
//  YAPPakistan_Example
//
//  Created by Umer on 23/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

final class RemoteFallBackToLocalProvider: FeatureFlagProvider {
    let localProvider: FeatureFlagProvider
    let remoteProvider: FeatureFlagProvider
    let defaultProvider: FeatureFlagProvider

    public init(localProvider: FeatureFlagProvider,
                remoteProvider: FeatureFlagProvider,
                defaultProvider: FeatureFlagProvider) {
        self.localProvider = localProvider
        self.remoteProvider = remoteProvider
        self.defaultProvider = defaultProvider
    }
    public func isFeatureEnabled(_ feature: String) -> Bool {
        var result = false
        result = remoteProvider.isFeatureEnabled(feature)
        if !result {
            result = localProvider.isFeatureEnabled(feature)
        }
        if !result {
            result = defaultProvider.isFeatureEnabled(feature)
        }
        return result
    }
}
