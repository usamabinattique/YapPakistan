//
//  AdjustAnalytics.swift
//  YAPSuperApp
//
//  Created by Najeeb on 16/03/2022.
//

import Adjust
import Foundation


protocol AdjustTracker {
    func trackEventWithToken(_ token: String, callbackId: String?,
                             callbackParameters: [String: String]?, andEventParameters eventParameters: [String: String]?)
}


struct AdjustAnalytics: AdjustTracker {
    
    func trackEventWithToken(_ token: String,
                             callbackId: String? = nil,
                             callbackParameters: [String : String]? = nil,
                             andEventParameters eventParameters: [String : String]? = nil) {
        
        let event = ADJEvent(eventToken: token)
        callbackId.map { event?.setCallbackId($0) }
        callbackParameters?.forEach {
            event?.addCallbackParameter($0.key, value: $0.value)
        }
        eventParameters?.forEach {
            event?.addPartnerParameter($0.key, value: $0.value)
        }
        Adjust.trackEvent(event)
    }
    
}
