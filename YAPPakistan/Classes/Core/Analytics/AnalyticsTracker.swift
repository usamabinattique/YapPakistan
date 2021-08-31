//
//  AnalyticsTracker.swift
//  YAPDependencyContainers
//
//  Created by UmerAfzal on 23/08/2021.
//

import Foundation

protocol AnalyticsEvent {
    var name: String {  get }
}

protocol AnalyticsTrackerType {
    func log(event: AnalyticsEvent)
}

class FirebaseAnalyticsTracker: AnalyticsTrackerType {
    func log(event: AnalyticsEvent) {
        
    }
}
