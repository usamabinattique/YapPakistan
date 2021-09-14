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
    init(store: CredentialsStoreType) {
        self.store = store
    }
    
    func makeSplashCoordinator(window: UIWindow) -> SplashCoordinator {
        SplashCoordinator(window: window, shortcutItem: nil, store: store)
    }
    
    func makePKApplication(window: UIWindow) -> YAPPakistan.AppCoordinator {
        let pkMainContainer = yapPakistanMainContainer()
        return pkMainContainer.rootCoordinator(window: window) 
    }
}
