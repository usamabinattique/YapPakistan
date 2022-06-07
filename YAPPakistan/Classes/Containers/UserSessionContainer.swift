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
        
        //!!!: I had to add it here because session timeout was being handled in service layer and service layer don't have access to required managers
        NotificationCenter.default.addObserver(self, selector: #selector(clearUserCreds), name: NSNotification.Name.init(.authenticationRequired), object: nil)
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
        return TransactionsRepository(transactionService: service, customersService: makeCustomersService())
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
    
    func makeMoreRepository() -> MoreRepository {
        let messageService = makeMessagesService()
        let authenticationService = parent.makeAuthenticationService()
        return MoreRepository(messagesService: messageService, authenticationService: authenticationService)
    }
    
    func makeAnalyticsRepository() -> AnalyticsRepositoryType {
        let service = makeTransactionsService()
        return AnalyticsRepository(service: service)
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
    
    func makeEditSendMoneyBeneficiaryViewController(sendMoneyType: SendMoneyType, beneficiary: SendMoneyBeneficiary) -> EditSendMoneyBeneficiaryViewController {
        
        let yapITRepository = makeYapItRepository()
        let viewModel: EditSendMoneyBeneficiaryViewModel
        
        ///if sendMoneyType == .local {
            viewModel = ESMBBankTransferViewModel(beneficiary: beneficiary, sendMoneyType: sendMoneyType, repository: yapITRepository)
        //}
        return EditSendMoneyBeneficiaryViewController(themeService: parent.themeService, viewModel)
    }
    
    func makeProfilePictureViewController(image: UIImage, beneficiary: SendMoneyBeneficiary) -> ProfilePictureViewController {
        
        let yapITRepository = makeYapItRepository()
        let viewModel = ProfilePictureViewModel(beneficiary: beneficiary, repository: yapITRepository, image: image)
        return ProfilePictureViewController(themeService: parent.themeService, viewModel)
    }
    
    func makeSendMoneyFundsTransferViewController(sendMoneyType: SendMoneyType, beneficiary: SendMoneyBeneficiary) -> SendMoneyFundsTransferViewController {
        
        let yapITRepository = makeYapItRepository()
        let viewModel: SendMoneyFundsTransferViewModel
        
        ///if sendMoneyType == .local {
        viewModel = SendMoneyFundsTransferViewModel(beneficiary: beneficiary, sendMoneyType: sendMoneyType, repository: makeY2YRepository(), accountProvider: accountProvider) //SendMoneyFundsTransferViewModel(beneficiary: beneficiary, sendMoneyType: sendMoneyType, repository: yapITRepository)
        //}
        return SendMoneyFundsTransferViewController(viewModel, themeService: parent.themeService) //EditSendMoneyBeneficiaryViewController(themeService: parent.themeService, viewModel)
    }
    
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
    
    func makeCardStatementWebViewController(viewModel: CardStatementWebViewModel) -> CardStatementWebViewController {
        return CardStatementWebViewController(themeService: self.themeService, viewModel: viewModel)
    }
    
    func makeTopupCardDetailViewController(externalCard: ExternalPaymentCard) -> TopUpCardDetailsViewController {
        let viewModel = TopUpCardDetailsViewModel(externalCard: externalCard, repository: self.makeCardsRepository())
        return TopUpCardDetailsViewController(themeService: self.themeService, viewModel: viewModel)
    }
    
    func makeTopupTransferViewController(paymentGatewayModel: PaymentGatewayLocalModel) -> TopupTransferViewController {
        let viewModel = TopupTransferViewModel(repository: self.makeTransactionsRepository(), paymentGatewayModel: paymentGatewayModel)
        return TopupTransferViewController(themeService: self.themeService, viewModel: viewModel)
    }
    
    // MARK: Coordinators
    func makeTopupTransferCoordinator(root: UINavigationController, paymentGatewayModel: PaymentGatewayLocalModel) -> TopupTransferCoordinator {
        TopupTransferCoordinator(root: root, container: self, paymentGatewayModel: paymentGatewayModel)
    }
    
    // MARK: Custom Methods
    @objc func clearUserCreds() {
        self.biometricsManager.deleteBiometryForUser(phone: self.parent.credentialsStore.getUsername() ?? "")
        self.parent.credentialsStore.clearCredentials()
    }
    
    // MARK -: Card Scheme
    
    func makeCardSchemeViewController() -> CardSchemeViewController {
        let viewModel = CardSchemeViewModel(self.makeKYCRepository(), accountProvider: self.accountProvider)
        return CardSchemeViewController(themeService: self.themeService, viewModel: viewModel)
    }
    
    
//    func makeCardNameCoordinator(root: UINavigationController,  schemeObj: KYCCardsSchemeM, paymentGatewayM: PaymentGatewayLocalModel) -> CardNameCoordinator {
//        CardNameCoordinator(root: root, container: self ,schemeObj: schemeObj, paymentGatewayM: paymentGatewayM)
//    }
    
    func makeCardBenefitsViewController() -> CardBenefitsViewController {
        let viewModel = CardBenefitsViewModel(self.makeKYCRepository(), transactionRepo: self.makeTransactionsRepository(), accountProvider: self.accountProvider)
        return CardBenefitsViewController(themeService: self.themeService, viewModel: viewModel)
    }
    
//    func makeMotherQuestionViewController() -> KYCQuestionsViewController {
//        return MotherQuestionModuleBuilder(container: self).viewController()
//    }
//
//    func makeCityQuestionViewController(motherName: String) -> KYCQuestionsViewController {
//        return CityQuestionModuleBuilder(container: self, motherName: motherName).viewController()
//    }
//
//    func makeSelfieGuidelineViewController() -> SelfieGuidelineViewController {
//        SelfieGuidelineModuleBuilder(container: self).viewController()
//    }
//
//    func makeCaptureViewController() -> CaptureViewController {
//        CaptureSelfieModuleBuilder(container: self).viewController()
//    }
//
//    func makeReviewSelfieViewController(image: UIImage) -> ReviewSelfieViewController {
//        ReviewSelfieModuleBuilder(container: self, image: image).viewController()
//    }
//
//    func makeCardNameViewController(paymentGatewayM: PaymentGatewayLocalModel) -> CardNameViewController {
//        CardNameModuleBuilder(container: self, paymentGatewayM: paymentGatewayM).viewController()
//    }
//
//    func makeEditCardNameViewController(name: String) -> EditCardNameViewController {
//        EditCardNameModuleBuilder(container: self).viewController(name: name)
//    }
//
//    func makeAddressViewController() -> AddressViewController {
//        AddressModuleBuilder(container: self).viewController()
//    }
//
//    func makeCityListViewController() -> CityListViewController {
//        CityListModuleBuilder(container: self).viewController()
//    }
//
//
//    func makeCardOnItsWayViewController() -> CardOnItsWayViewController {
//        CardOnItsWayModuleBuilder(container: self).viewController()
//    }
//
//    func makeManualVerificationViewController() -> ManualVerificationViewController {
//        ManualVerificationModuleBuilder(container: self).viewController()
//    }
}
