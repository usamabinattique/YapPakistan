//
//  YAPPakistanMainContainer.swift
//  YAPPakistan
//
//  Created by Umer on 04/09/2021.
//

import Foundation
import RxSwift
import RxTheme

public struct YAPPakistanConfiguration {
    let environment: String
    public init(environment: String) {
        self.environment = environment
    }
}

public final class YAPPakistanMainContainer {
    let configuration: YAPPakistanConfiguration
    let themeService: ThemeService<AppTheme>

    public init(configuration: YAPPakistanConfiguration) {
        self.configuration = configuration
        self.themeService = AppTheme.service(initial: .light)
    }
    
    public func rootCoordinator(window: UIWindow) -> AppCoordinator {
        AppCoordinator(window: window, shortcutItem: nil, container: self)
    }

    func makeAPIClient() -> APIClient {
        return WebClient()
    }

    func makeAPIConfiguration() -> APIConfiguration {
        return APIConfiguration(environment: configuration.environment)
    }

    func makeAuthorizationProvider(xsrfToken: String) -> ServiceAuthorizationProviderType {
        return GuestServiceAuthorization(xsrf: xsrfToken)
    }

    func makeCustomersService(xsrfToken: String) -> CustomersService {
        return CustomersService(apiClient: makeAPIClient(),
                                apiConfig: makeAPIConfiguration(),
                                authorizationProvider: makeAuthorizationProvider(xsrfToken: xsrfToken))
    }

    func makeCustomersService(authorizationProvider: ServiceAuthorizationProviderType) -> CustomersService {
        return CustomersService(apiClient: makeAPIClient(),
                                apiConfig: makeAPIConfiguration(),
                                authorizationProvider: authorizationProvider)
    }

    func makeMessagesService(xsrfToken: String) -> MessagesService {
        return MessagesService(apiClient: makeAPIClient(),
                               apiConfig: makeAPIConfiguration(),
                               authorizationProvider: makeAuthorizationProvider(xsrfToken: xsrfToken))
    }

    func makeMessagesService(authorizationProvider: ServiceAuthorizationProviderType) -> MessagesService {
        return MessagesService(apiClient: makeAPIClient(),
                               apiConfig: makeAPIConfiguration(),
                               authorizationProvider: authorizationProvider)
    }

    public func makeDummyViewController(xsrfToken: String) -> UIViewController {
        let customerService = CustomersService(apiConfig: makeAPIConfiguration(),
                                               authorizationProvider: makeAuthorizationProvider(xsrfToken: xsrfToken))
        return UIViewController()
    }
}
