//
//  YAPPakistanMainContainer.swift
//  YAPPakistan
//
//  Created by Umer on 04/09/2021.
//

import Foundation
import RxSwift
import RxTheme

public enum Environment {
    case dev
    case qa
    case stg
    case preprod
    case prod
}

public struct YAPPakistanConfiguration {
    let environment: Environment

    public init(environment: Environment) {
        self.environment = environment
    }
}

public final class YAPPakistanMainContainer {
    let configuration: YAPPakistanConfiguration
    let themeService: ThemeService<AppTheme>
    let credentialsStore: CredentialsStoreType
    var xsrfToken:String! = nil

    public init(configuration: YAPPakistanConfiguration) {
        self.configuration = configuration
        self.themeService = AppTheme.service(initial: .light)
        self.credentialsStore = CredentialsManager()
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
    
    func makeAuthenticationService(xsrfToken: String) -> AuthenticationService {
        return AuthenticationService(apiClient: makeAPIClient(), authorizationProvider: makeAuthorizationProvider(xsrfToken: xsrfToken))
    }

    func makeReachedQueueTopViewController() -> ReachedQueueTopViewController {
        let viewModel = ReachedQueueTopViewModel()
        let viewController = ReachedQueueTopViewController(themeService: themeService, viewModel: viewModel)

        return viewController
    }

    public func makeDummyViewController(xsrfToken: String) -> UIViewController {
        let customerService = CustomersService(apiConfig: makeAPIConfiguration(),
                                               authorizationProvider: makeAuthorizationProvider(xsrfToken: xsrfToken))
        return UIViewController()
    }
}

extension YAPPakistanMainContainer {
    func makeLoginRepository() -> LoginRepository {
        return LoginRepository(customerService: self.makeCustomersService(xsrfToken: xsrfToken), authenticationService: makeAuthenticationService(xsrfToken: xsrfToken), messageService: makeMessagesService(xsrfToken: xsrfToken))
    }

    func makeLoginViewModel(loginRepository:LoginRepository, user:OnBoardingUser = OnBoardingUser(accountType: .b2cAccount)) -> LoginViewModelType {
        return LoginViewModel(repository: loginRepository, credentialsManager: self.credentialsStore, user: user)
    }

    func makeLoginViewController(viewModel:LoginViewModelType, isBackButton: Bool = true) -> LoginViewController {
        return LoginViewController(themeService: self.themeService, viewModel: viewModel, isBackButton: isBackButton)
    }
    
}
