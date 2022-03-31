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
    private(set) var analytics: AnalyticsTracker
    private(set) var eventCallback: ((PKAppEvent) -> Void)?
    private(set) var notificationHandler: NotificationHandlerDelegate
    private(set) var deeplinkHandler: DeepLinkHandlerDelegate

    public init(environment: AppEnvironment = .qa,
                googleMapsAPIKey: String = "",
                analytics: AnalyticsTracker,
                buildConfig: (version: String, build: String) = ("", ""),
                notificationHandler: NotificationHandlerDelegate,
                deeplinkHandler: DeepLinkHandlerDelegate,
                callback: ((PKAppEvent) -> Void)?) {
        
        self.environment = environment
        self.googleMapsAPIKey = googleMapsAPIKey
        self.eventCallback = callback
        self.analytics = analytics
        self.buildConfig = buildConfig
        self.notificationHandler = notificationHandler
        self.deeplinkHandler = deeplinkHandler
    }
}
