//
//  JourneyTracker.swift
//  YAPDependencyContainers
//
//  Created by UmerAfzal on 23/08/2021.
//

import Foundation

protocol JourneyEvent {
    var name: String {  get }
}

protocol JourneyTrackerType {
    func log(event: JourneyEvent)
}

class LeanplumJourneyTracker: JourneyTrackerType {
    func log(event: JourneyEvent) {
        
    }
}

