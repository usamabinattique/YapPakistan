//
//  LeanplumAnalytics.swift
//  YAPSuperApp
//
//  Created by Najeeb on 16/03/2022.
//

import Foundation
import Leanplum


protocol LeanplumTracker {
    func trackEvent(_ event: String, withParameters parameters: [String: Any])
    func setUserAttributes(_ attributes: [String: Any])
}


struct LeanplumAnalytics: LeanplumTracker {
    
    func trackEvent(_ event: String, withParameters parameters: [String: Any]) {
        Leanplum.track(event, params: parameters)
    }
    
    func setUserAttributes(_ attributes: [String: Any]) {
        Leanplum.setUserAttributes(attributes)
    }
    
}
