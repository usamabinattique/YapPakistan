//
//  AnalyticsTracker.swift
//  YAPDependencyContainers
//
//  Created by UmerAfzal on 23/08/2021.
//

import Foundation

typealias AnalyticsParameter = [String: Any]
typealias AnalyticsUserData = [String: String]

protocol AnalyticsEvent {
    var name: String { get }
    var payload: AnalyticsParameter? { get }
}

protocol AnalyticsTrackerType {
    func log(event: AnalyticsEvent)
}

class FirebaseAnalyticsTracker: AnalyticsTrackerType {
    init(userId: String?, userData: AnalyticsUserData?) {
    }
    func setUserData(userId: String, userData: AnalyticsUserData?) {

    }
    func log(event: AnalyticsEvent) {
    }
}
