//
//  FeatureFlagProvider.swift
//  YAPPakistan_Example
//
//  Created by Umer on 23/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

protocol FeatureFlagProvider {
    func isFeatureEnabled(_ feature: String) -> Bool
}
