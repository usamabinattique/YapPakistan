//
//  FeatureTracker.swift
//  YAPDependencyContainers
//
//  Created by UmerAfzal on 23/08/2021.
//

import Foundation

protocol FeatureEvent {
    var name: String {  get }
}

protocol FeatureTrackerType {
    func log(event: FeatureEvent)
}

class AdjustFeatureTracker: FeatureTrackerType {
    func log(event: FeatureEvent) {
        
    }
}
