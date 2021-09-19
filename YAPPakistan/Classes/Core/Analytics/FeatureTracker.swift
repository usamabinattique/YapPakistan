//
//  FeatureTracker.swift
//  YAPDependencyContainers
//
//  Created by UmerAfzal on 23/08/2021.
//

import Foundation

protocol FeatureEvent {
    var token: String { get }
    var payload: AnalyticsParameter? { get }
}

protocol FeatureTrackerType {
    func log(event: FeatureEvent)
}

class AdjustFeatureTracker: FeatureTrackerType {
    init(userId: String?, userData: AnalyticsUserData?) {
    }
    func setUserData(userId: String, userData: AnalyticsUserData?) {

    }
    func log(event: FeatureEvent) {

    }
}
