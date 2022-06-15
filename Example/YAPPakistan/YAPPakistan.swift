//
//  YAPPakistan.swift
//  YAPPakistan_Example
//
//  Created by Umair  on 05/06/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import YAPPakistan

let eventCallback: (PKAppEvent) -> Void = { event in }
func yapPakistanMainContainer() -> YAPPakistanMainContainer {
    let configuration = YAPPakistanConfiguration(environment: .current,
                                                 googleMapsAPIKey: "AIzaSyCy_1KJ3iHy2SSQDo3Q35YS96vNDx4xZuI",
                                                 analytics: makeAnalyticsTracker(),
                                                 buildConfig: ("1.0", "1.0"),
                                                 callback: eventCallback)
    
    return YAPPakistanMainContainer(configuration: configuration)
}

private func makeAnalyticsTracker() -> AnalyticsHandler {
    return AnalyticsHandler(leanplumTracker: LeanplumAnalytics(),
                            adjustTracker: AdjustAnalytics(),
                            firebaseTracker: FirebaseAnalytics())
}
