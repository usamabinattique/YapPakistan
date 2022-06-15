//
//  FirebaseAnalytics.swift
//  YAPSuperApp
//
//  Created by Najeeb on 16/03/2022.
//

import FirebaseAnalytics
import Foundation


protocol FirebaseTracker {
    func trackEvent(_ name: String, withParameters parameters: [String: Any])
}


struct FirebaseAnalytics: FirebaseTracker {
    
    func trackEvent(_ name: String, withParameters parameters: [String: Any]) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
}
