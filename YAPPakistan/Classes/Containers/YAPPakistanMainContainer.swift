//
//  YAPPakistanMainContainer.swift
//  YAPPakistan
//
//  Created by Umer on 04/09/2021.
//

import Foundation
import RxSwift
import RxTheme
import YAPCore
import PhoneNumberKit

public struct YAPPakistanConfiguration {
    let environment: AppEnvironment

    public init(environment: AppEnvironment) {
        self.environment = environment
    }
}

public final class YAPPakistanMainContainer {
    let configuration: YAPPakistanConfiguration
    let themeService: ThemeService<AppTheme>
    let credentialsStore: CredentialsStoreType
    let referralManager: AppReferralManager
    var xsrfToken:String! = nil

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
        return WebClient(apiConfig: makeAPIConfiguration())
    }

    func makeAPIConfiguration() -> APIConfiguration {
        return APIConfiguration(environment: configuration.environment)
    }

    func makeAuthorizationProvider(xsrfToken: String) -> ServiceAuthorizationProviderType {
        return GuestServiceAuthorization(xsrf: xsrfToken)
    }

    func makeXSRFService() -> XSRFService {
        return XSRFService(apiConfig: makeAPIConfiguration(),
                           apiClient: makeAPIClient())
    }

    func makeCustomersService(xsrfToken: String) -> CustomersService {
        return CustomersService(apiConfig: makeAPIConfiguration(),
                                apiClient: makeAPIClient(),
                                authorizationProvider: makeAuthorizationProvider(xsrfToken: xsrfToken))
    }

    func makeCustomersService(authorizationProvider: ServiceAuthorizationProviderType) -> CustomersService {
        return CustomersService(apiConfig: makeAPIConfiguration(),
                                apiClient: makeAPIClient(),
                                authorizationProvider: authorizationProvider)
    }

    func makeMessagesService(xsrfToken: String) -> MessagesService {
        return MessagesService(apiConfig: makeAPIConfiguration(),
                               apiClient: makeAPIClient(),
                               authorizationProvider: makeAuthorizationProvider(xsrfToken: xsrfToken))
    }

    func makeMessagesService(authorizationProvider: ServiceAuthorizationProviderType) -> MessagesService {
        return MessagesService(apiConfig: makeAPIConfiguration(),
                               apiClient: makeAPIClient(),
                               authorizationProvider: authorizationProvider)
    }

    func makeAuthenticationService(xsrfToken: String) -> AuthenticationService {
        return AuthenticationService(apiConfig: makeAPIConfiguration(),
                                     apiClient: makeAPIClient(),
                                     authorizationProvider: makeAuthorizationProvider(xsrfToken: xsrfToken))
    }

    func makeAuthenticationService(authorizationProvider: ServiceAuthorizationProviderType) -> AuthenticationService {
        return AuthenticationService(apiConfig: makeAPIConfiguration(),
                                     apiClient: makeAPIClient(),
                                     authorizationProvider: authorizationProvider)
    }

    func makeSplashRepository() -> SplashRepository {
        return SplashRepository(service: makeXSRFService())
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

        let enterEmailViewModel = EnterEmailViewModel(credentialsStore: credentialsStore,
                                                      referralManager: referralManager,
                                                      sessionProvider: sessionProvider,
                                                      onBoardingRepository: onBoardingRepository, user: user) { session, accountProvider, onBoardingRepository, demographicsRepository in
            let sessionContainer = UserSessionContainer(parent: self, session: session)
            accountProvider = sessionContainer.accountProvider
            onBoardingRepository = sessionContainer.makeOnBoardingRepository()
            demographicsRepository = sessionContainer.makeDemographicsRepository()
        }

        return EnterEmailViewController(themeService: themeService, viewModel: enterEmailViewModel)
    }

    func makeWaitingListController(session: Session) -> WaitingListRankViewController {
        let sessionContainer = UserSessionContainer(parent: self, session: session)
        return sessionContainer.makeWaitingListController()
    }

    public func makeDummyViewController(xsrfToken: String) -> UIViewController {
        let customerService = CustomersService(apiConfig: makeAPIConfiguration(),
                                               apiClient: makeAPIClient(),
                                               authorizationProvider: makeAuthorizationProvider(xsrfToken: xsrfToken))
        return UIViewController()
    }
}

extension YAPPakistanMainContainer {
    func makeLoginRepository() -> LoginRepository {
        return LoginRepository(customerService: self.makeCustomersService(xsrfToken: xsrfToken),
                               authenticationService: makeAuthenticationService(xsrfToken: xsrfToken),
                               messageService: makeMessagesService(xsrfToken: xsrfToken))
    }

    func makeLoginViewModel(loginRepository:LoginRepository,
                            user:OnBoardingUser = OnBoardingUser(accountType: .b2cAccount)) -> LoginViewModelType {
        return LoginViewModel(repository: loginRepository, credentialsManager: self.credentialsStore, phoneNumberKit: PhoneNumberKit())
    }

    func makeLoginViewController(viewModel:LoginViewModelType) -> LoginViewController {
        return LoginViewController(themeService: self.themeService, viewModel: viewModel)
    }
    
}

extension YAPPakistanMainContainer {
    func makeBiometricsManager() -> BiometricsManager {
        return BiometricsManager()
    }

    func makeVerifyPasscodeViewModel(onLogin: @escaping VerifyPasscodeViewModelType.OnLoginClosure) -> VerifyPasscodeViewModelType {
        return VerifyPasscodeViewModel(username: credentialsStore.getUsername() ?? "",
                                       repository: makeLoginRepository(),
                                       credentialsManager: credentialsStore,
                                       sessionCreator: SessionProvider(xsrfToken: xsrfToken),
                                       onLogin: onLogin)
    }
    
    func makeVerifyPasscodeViewController(viewModel:VerifyPasscodeViewModelType,
                               biometricsService: BiometricsManager = BiometricsManager(),
                               isCreatePasscode:Bool = false) -> VerifyPasscodeViewController {
        return VerifyPasscodeViewController(themeService: themeService,
                                            viewModel: viewModel,
                                            biometricsService: biometricsService)
    }
    
    func makePasscodeCoordinator(root:UINavigationController) -> PasscodeCoordinatorPushable  {
        PasscodeCoordinatorPushable(root: root, xsrfToken: xsrfToken, container: self)
    }
}


extension YAPPakistanMainContainer {

    func makeOTPRepository(messageService:MessagesService, customerService:CustomersService) -> OTPRepositoryType {
        return OTPRepository(messageService: messageService, customerService: customerService)
    }

    func makeSessionProvider(xsrfToken:String) -> SessionProviderType {
        SessionProvider(xsrfToken: xsrfToken)
    }

    func makeLoginOTPVerificationViewModel(otpRepository:OTPRepositoryType,
                                           sessionProvider:SessionProviderType,
                                           userName:String,
                                           passcode:String,
                                           logo:UIImage? = UIImage(named: "icon_app_logo", in: .yapPakistan),
                                           headingKey:String = "screen_device_registration_otp_display_header_message".localized,
                                           otpMessageKey:String = "screen_device_registration_otp_display_givn_text_message".localized,
                                           onLogin:@escaping (Session, inout AccountProvider?, inout DemographicsRepositoryType?) -> Void
    ) -> LoginOTPVerificationViewModel {

        return LoginOTPVerificationViewModel(action: .deviceVerification,
                                                      heading: headingKey.localized,
                                                      subheading: String(format: otpMessageKey, userName.toFormatedPhoneNumber),
                                                      image: logo,
                                                      repository: otpRepository,
                                                      username: userName,
                                                      passcode: passcode,
                                                      sessionCreator: sessionProvider,
                                                      onLogin: onLogin )
    }

    func makeVerifyMobileOTPViewController(viewModel: LoginOTPVerificationViewModel) -> VerifyMobileOTPViewController {
        return VerifyMobileOTPViewController(themeService: self.themeService, viewModel: viewModel)
    }
}
