//
//  AnalyticsHandler.swift
//  YAPSuperApp
//
//  Created by Najeeb on 16/03/2022.
//

import Foundation
import Leanplum
import YAPCore

class AnalyticsHandler {
    
    private let leanplumTracker: LeanplumTracker
    private let adjustTracker: AdjustTracker
    private let firebaseTracker: FirebaseTracker
    
    init(leanplumTracker: LeanplumTracker, adjustTracker: AdjustTracker, firebaseTracker: FirebaseTracker) {
        self.leanplumTracker = leanplumTracker
        self.adjustTracker = adjustTracker
        self.firebaseTracker = firebaseTracker
    }
    
}
  

extension AnalyticsHandler: AnalyticsTracker {
    
    // Firebase Methods
    func trackFirebaseEvent(_ eventName: String,
                            withParameters eventParameters: [String: Any]) {
        firebaseTracker.trackEvent(eventName, withParameters: eventParameters)
    }
    
    // Adjust Methods
    func trackAdjustEventWithToken(_ eventToken: String,
                                   customerId: String? = nil,
                                   andParameters parameters: [String: Any]? = nil) {
        
        let callbackParams = customerId.map { ["account_id": $0]}
        var eventParams = [String: String]()
        parameters?.forEach {
            if let value = $0.value as? String {
                eventParams[$0.key] = value
            }
        }
        adjustTracker.trackEventWithToken(eventToken,
                                          callbackId: customerId,
                                          callbackParameters: callbackParams,
                                          andEventParameters: eventParams)
    }
    
    // Leanplum Methods
    func trackLeanplumEvent(_ event: String,
                            withParameters parameters: [String: Any]) {
        leanplumTracker.trackEvent(event, withParameters: parameters)
    }
    
    func setLeanplumUserAttributes(_ attributes: [String: Any]) {
        leanplumTracker.setUserAttributes(attributes)
    }
    
}

