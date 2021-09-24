//
//  SelectCountry.swift
//  YAPPakistan_Example
//
//  Created by Umer on 04/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import YAPCore
import YAPPakistan

final class DemoApplicationContainer {
    let store: CredentialsStoreType
    let featureFlagProvider: RemoteFallBackToLocalProvider!

    init(store: CredentialsStoreType) {
        self.store = store
        // setup feature flag provider
        let jsonFileURL = Bundle.main.url(forResource: "DefaultFeatureFlags", withExtension: "json")!
        let handler = FeatureFlagFileManager()
        let remoteProvider = RemoteFeatureFlagProvider(databaseHandler: handler)
        let localProvider = LocalFeatureFlagProvider(databaseHandler: handler)
        let defaultProvider = DefaultFeatureFlagProvider(jsonUrl: jsonFileURL)
        featureFlagProvider = RemoteFallBackToLocalProvider(localProvider: localProvider,
                                                            remoteProvider: remoteProvider,
                                                            defaultProvider: defaultProvider)
    }
    
    func makeSplashCoordinator(window: UIWindow) -> SplashCoordinator {
        SplashCoordinator(window: window, shortcutItem: nil, store: store)

    }
    
    func makePKApplication(window: UIWindow) -> YAPPakistan.AppCoordinator {
        if featureFlagProvider.isFeatureEnabled("YP-PK") {
            let pkMainContainer = yapPakistanMainContainer()
            return pkMainContainer.rootCoordinator(window: window)
        }
        fatalError()
    }
}
