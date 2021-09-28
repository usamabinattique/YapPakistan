//
//  UserSessionContainer.swift
//  YAPPakistan
//
//  Created by Tayyab on 14/09/2021.
//

import Foundation
import RxTheme

public final class UserSessionContainer {
    let parent: YAPPakistanMainContainer
    let session: Session
    let accountProvider: AccountProvider
    let biometricsManager: BiometricsManager = BiometricsManager()

    init(parent: YAPPakistanMainContainer, session: Session) {
        self.parent = parent
        self.session = session

        let authService = parent.makeAuthenticationService(authorizationProvider: session)
        let customersService = parent.makeCustomersService(authorizationProvider: session)
        let repository = AccountRepository(authenticationService: authService, customerService: customersService)

        self.accountProvider = AccountProvider(repository: repository)
    }

    // MARK: Properties

    var themeService: ThemeService<AppTheme> {
        return parent.themeService
    }

    // MARK: Repositories

    func makeAccountRepository() -> AccountRepository {
        let authService = parent.makeAuthenticationService(authorizationProvider: session)
        let customersService = parent.makeCustomersService(authorizationProvider: session)
        let repository = AccountRepository(authenticationService: authService, customerService: customersService)

        return repository
    }

    func makeDemographicsRepository() -> DemographicsRepositoryType {
        let customersService = parent.makeCustomersService(authorizationProvider: session)
        let repository = DemographicsRepository(customersService: customersService)

        return repository
    }

    func makeOnBoardingRepository() -> OnBoardingRepository {
        let customersService = parent.makeCustomersService(authorizationProvider: session)
        let messagesService = parent.makeMessagesService(authorizationProvider: session)
        let onBoardingRepository = OnBoardingRepository(customersService: customersService, messagesService: messagesService)

        return onBoardingRepository
    }

    func makeLoginRepository() -> LoginRepository {
        let customersService = parent.makeCustomersService(authorizationProvider: session)
        let authService = parent.makeAuthenticationService(authorizationProvider: session)
        let messagesService = parent.makeMessagesService(authorizationProvider: session)
        let loginRepository = LoginRepository(customerService: customersService,
                                              authenticationService: authService,
                                              messageService: messagesService)

        return loginRepository
    }

    func makeKYCRepository() -> KYCRepository {
        let customersService = parent.makeCustomersService(authorizationProvider: session)
        let kycRepository = KYCRepository(customersService: customersService)

        return kycRepository
    }

    // MARK: Controllers

    func makeWaitingListController() -> WaitingListRankViewController {
        let onBoardingRepository = makeOnBoardingRepository()
        let viewModel = WaitingListRankViewModel(accountProvider: accountProvider, referralManager: parent.referralManager, onBoardingRepository: onBoardingRepository)

        return WaitingListRankViewController(themeService: parent.themeService, viewModel: viewModel)
    }

    func makeReachedQueueTopViewController() -> ReachedQueueTopViewController {
        let viewModel = ReachedQueueTopViewModel(accountProvider: accountProvider,
                                                 accountRepository: makeAccountRepository())
        let viewController = ReachedQueueTopViewController(themeService: parent.themeService,
                                                           viewModel: viewModel)

        return viewController
    }

    func makeLiteDashboardViewController() -> LiteDashboardViewController {
        let viewModel = LiteDashboardViewModel(accountProvider: accountProvider,
                                               biometricsManager: biometricsManager,
                                               credentialStore: parent.credentialsStore,
                                               repository: makeLoginRepository())
        let viewController = LiteDashboardViewController(themeService: parent.themeService,
                                                         viewModel: viewModel)

        return viewController
    }
}
