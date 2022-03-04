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

    // MARK: Services

    func makeTransactionsService() -> TransactionsService {
        TransactionsService(apiConfig: parent.makeAPIConfiguration(),
                            apiClient: parent.makeAPIClient(),
                            authorizationProvider: session)
    }

    func makeCustomersService() -> CustomersService {
        return parent.makeCustomersService(authorizationProvider: session)
    }

    // Session Based
    func makeCardsService() -> CardsService {
        return CardsService(apiConfig: parent.makeAPIConfiguration(),
                            apiClient: parent.makeAPIClient(),
                            authorizationProvider: session)
    }

    func makeMessagesService() -> MessagesServiceType {
        return MessagesService(apiConfig: parent.makeAPIConfiguration(),
                               apiClient: parent.makeAPIClient(),
                               authorizationProvider: session)
    }

    // MARK: Repositories

    func makeYapItRepository() -> YapItRepository {
        let service = makeCustomersService()
        return YapItRepository(customersService: service)
    }
    
    func makeY2YRepository() -> Y2YRepository {
        return Y2YRepository(customersService: makeCustomersService(), transactionService: makeTransactionsService())
    }
    
    func makeYapInviteFriendRepository() -> YAPInviteFriendRepository {
        return YAPInviteFriendRepository(customersService: makeCustomersService(), accountProvider: makeAccountProvider())
    }
    
    func makeTransactionsRepository() -> TransactionsRepository {
        let service = makeTransactionsService()
        return TransactionsRepository(transactionService: service)
    }

    func makeOTPRepository() -> OTPRepositoryType {
        let messageService = makeMessagesService()
        let customerService = makeCustomersService()
        return OTPRepository(messageService: messageService, customerService: customerService)
    }

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
        let cardsService = makeCardsService()

        let kycRepository = KYCRepository(customersService: customersService,
                                          cardsService: cardsService)
        return kycRepository
    }

    func makeCardsRepository() -> CardsRepositoryType {
        let cardsService = makeCardsService()
        let customerService = makeCustomersService()
        let messagesService = makeMessagesService()
        let transactionsService = makeTransactionsService()
        return CardsRepository(cardsService: cardsService,
                               customerService: customerService,
                               messagesService: messagesService,
                               transactionsService: transactionsService)
    }
    
    // MARK: Account Provider
    
    func makeAccountProvider() -> AccountProvider {
        return AccountProvider(repository: makeAccountRepository())
    }

    // MARK: Custom Views
    func makeRecentBeneficiaryView() -> RecentBeneficiaryView {
        let recentBeneficiaryView = RecentBeneficiaryView(with: themeService)
        recentBeneficiaryView.showsSaperator = false
        recentBeneficiaryView.translatesAutoresizingMaskIntoConstraints = false
        return recentBeneficiaryView
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

    func makeHomeViewController() -> HomeViewController {
        return HomeModuleBuilder(container: self).viewController()
    }
    
    func makeCommonWebViewController(viewModel: CommonWebViewModel) -> CommonWebViewController {
        return CommonWebViewController(themeService: self.themeService, viewModel: viewModel)
    }
    
    func makeTopupCardDetailViewController(externalCard: ExternalPaymentCard) -> TopUpCardDetailsViewController {
        let viewModel = TopUpCardDetailsViewModel(externalCard: externalCard, repository: self.makeCardsRepository())
        return TopUpCardDetailsViewController(themeService: self.themeService, viewModel: viewModel)
    }
}
