//
//  YAPPakistanMainContainer.swift
//  YAPPakistan
//
//  Created by Umer on 04/09/2021.
//

import Foundation
import RxSwift

public struct YAPPakistanConfiguration {
    let environment: String
    public init(environment: String) {
        self.environment = environment
    }
}

public final class YAPPakistanMainContainer {
    let configuration: YAPPakistanConfiguration
    public init(configuration: YAPPakistanConfiguration) {
        self.configuration = configuration
    }
    
    public func rootCoordinator(window: UIWindow) -> AppCoordinator {
        AppCoordinator(window: window, shortcutItem: nil, container: self)
    }
    
    public func makeDummyViewController(xsrfToken: String) -> UIViewController {
        let customerService = CustomersService(apiConfig: APIConfiguration(environment: configuration.environment),
                                               authorizationProvider: GuestServiceAuthorization(xsrf: xsrfToken))
        return UIViewController()
    }
}
