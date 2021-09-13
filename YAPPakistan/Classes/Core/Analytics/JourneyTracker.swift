//
//  JourneyTracker.swift
//  YAPDependencyContainers
//
//  Created by UmerAfzal on 23/08/2021.
//

import Foundation

protocol JourneyEvent {
    var name: String {  get }
    var payload: AnalyticsParameter? {  get }
}

protocol JourneyTrackerType {
    func log(event: JourneyEvent)
}

class LeanplumJourneyTracker: JourneyTrackerType {
    init(userId: String?, userData: AnalyticsUserData?) {
    }
    func setUserData(userId: String, userData: AnalyticsUserData?) {
    }
    func log(event: JourneyEvent) {
        
    }
}

