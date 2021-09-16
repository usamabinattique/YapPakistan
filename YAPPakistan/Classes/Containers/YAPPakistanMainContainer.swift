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
    let referralManager: AppReferralManager

    public init(configuration: YAPPakistanConfiguration) {
        self.configuration = configuration
        self.themeService = AppTheme.service(initial: .light)
        self.credentialsStore = CredentialsManager()
        self.referralManager = AppReferralManager(environment: configuration.environment)
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

    func makeOnBoardingRepository(xsrfToken: String) -> OnBoardingRepository {
        let customersService = makeCustomersService(xsrfToken: xsrfToken)
        let messagesService = makeMessagesService(xsrfToken: xsrfToken)
        let onBoardingRepository = OnBoardingRepository(customersService: customersService, messagesService: messagesService)

        return onBoardingRepository
    }

    func makeEnterEmailController(xsrfToken: String, user: OnBoardingUser) -> EnterEmailViewController {
        let sessionProvider = SessionProvider(xsrfToken: xsrfToken)
        let onBoardingRepository = makeOnBoardingRepository(xsrfToken: xsrfToken)

        let enterEmailViewModel = EnterEmailViewModel(credentialsStore: credentialsStore, referralManager: referralManager, sessionProvider: sessionProvider, onBoardingRepository: onBoardingRepository, user: user) { session, onBoardingRepository, accountProvider in
            let sessionContainer = UserSessionContainer(parent: self, session: session)
            onBoardingRepository = sessionContainer.makeOnBoardingRepository()
            accountProvider = sessionContainer.accountProvider
        }

        return EnterEmailViewController(themeService: themeService, viewModel: enterEmailViewModel)
    }

    func makeWaitingListController(session: Session) -> WaitingListRankViewController {
        let sessionContainer = UserSessionContainer(parent: self, session: session)
        return sessionContainer.makeWaitingListController()
    }

    public func makeDummyViewController(xsrfToken: String) -> UIViewController {
        let customerService = CustomersService(apiConfig: makeAPIConfiguration(),
                                               authorizationProvider: makeAuthorizationProvider(xsrfToken: xsrfToken))
        return UIViewController()
    }
}
