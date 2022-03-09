//
//  YAPPakistanConfiguration.swift
//  YAPPakistan
//
//  Created by Zara on 24/02/2022.
//

import Foundation
import YAPCore

public class YAPPakistanConfiguration {
    private(set) var environment: AppEnvironment
    private(set) var googleMapsAPIKey : String
    private(set) var buildConfig: (version: String, build: String)
   //private(set) var analytics: AnalyticsEventService?
    private(set) var eventCallback: ((PKAppEvent) -> Void)?

    public init(environment: AppEnvironment = .qa, googleMapsAPIKey: String = ""/*, analytics: AnalyticsEventService? = nil*/, buildConfig: (version: String, build: String) = ("", ""), callback: ((PKAppEvent) -> Void)?) {
        self.environment = environment
        self.googleMapsAPIKey = googleMapsAPIKey
        self.eventCallback = callback
        //self.analytics = analytics
        self.buildConfig = buildConfig
        
    }
}
