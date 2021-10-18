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

    public init(configuration: YAPPakistanConfiguration) {
        self.configuration = configuration
        self.themeService = AppTheme.service(initial: .light)
        self.credentialsStore = CredentialsManager()
        self.referralManager = AppReferralManager(environment: configuration.environment)
    }

    public func rootCoordinator(window: UIWindow,
                                navigationController: UINavigationController,
                                flow: Flow) -> AppCoordinator {
        AppCoordinator(window: window,
                       navigationController: navigationController,
                       shortcutItem: nil,
                       container: self,
                       flow: flow)
    }

    func makeAPIClient() -> APIClient {
        return WebClient(apiConfig: makeAPIConfiguration())
    }

    func makeAPIConfiguration() -> APIConfiguration {
        return APIConfiguration(environment: configuration.environment)
    }

    func makeAuthorizationProvider() -> ServiceAuthorizationProviderType {
        return GuestServiceAuthorization()
    }

    func makeXSRFService() -> XSRFService {
        return XSRFService(apiConfig: makeAPIConfiguration(),
                           apiClient: makeAPIClient())
    }

    func makeCustomersService() -> CustomersService {
        return CustomersService(apiConfig: makeAPIConfiguration(),
                                apiClient: makeAPIClient(),
                                authorizationProvider: makeAuthorizationProvider())
    }

    func makeCustomersService(authorizationProvider: ServiceAuthorizationProviderType) -> CustomersService {
        return CustomersService(apiConfig: makeAPIConfiguration(),
                                apiClient: makeAPIClient(),
                                authorizationProvider: authorizationProvider)
    }

    func makeMessagesService() -> MessagesService {
        return MessagesService(apiConfig: makeAPIConfiguration(),
                               apiClient: makeAPIClient(),
                               authorizationProvider: makeAuthorizationProvider())
    }

    func makeMessagesService(authorizationProvider: ServiceAuthorizationProviderType) -> MessagesService {
        return MessagesService(apiConfig: makeAPIConfiguration(),
                               apiClient: makeAPIClient(),
                               authorizationProvider: authorizationProvider)
    }

    func makeAuthenticationService() -> AuthenticationService {
        return AuthenticationService(apiConfig: makeAPIConfiguration(),
                                     apiClient: makeAPIClient(),
                                     authorizationProvider: makeAuthorizationProvider())
    }

    func makeAuthenticationService(authorizationProvider: ServiceAuthorizationProviderType) -> AuthenticationService {
        return AuthenticationService(apiConfig: makeAPIConfiguration(),
                                     apiClient: makeAPIClient(),
                                     authorizationProvider: authorizationProvider)
    }

    func makeSplashRepository() -> SplashRepository {
        return SplashRepository(service: makeXSRFService())
    }

    public func makeOnBoardingRepository() -> OnBoardingRepository {
        let customersService = makeCustomersService()
        let messagesService = makeMessagesService()
        let onBoardingRepository = OnBoardingRepository(customersService: customersService,
                                                        messagesService: messagesService)
        return onBoardingRepository
    }

    func makeOnboardingCoordinator(user: OnBoardingUser,
                                   navigationController: UINavigationController) -> B2COnBoardingCoordinator {
        let container = OnboardingContainer(user: user, parent: self)
        return container.makeOnboardingCoordinator(navigationController: navigationController)
    }

    func makeWaitingListController(session: Session) -> WaitingListRankViewController {
        let sessionContainer = UserSessionContainer(parent: self, session: session)
        return sessionContainer.makeWaitingListController()
    }

    func makeWelcomeCoordinator(window: UIWindow) -> WelcomeCoordinatorReplaceable {
        return WelcomeCoordinatorReplaceable(container: self, window: window)
    }

    func makePasscodeCoordinatorReplaceable(window: UIWindow) -> PasscodeCoordinatorReplaceable {
        return PasscodeCoordinatorReplaceable(window: window, container: self, isUserBlocked: false)
    }

    func makeLoginCoordinatorReplaceable(window: UIWindow) -> LoginCoordinatorReplaceable {
        return LoginCoordinatorReplaceable(container: self, window: window)
    }
}

extension YAPPakistanMainContainer {
    public func makeLoginRepository() -> LoginRepository {
        return LoginRepository(customerService: self.makeCustomersService(),
                               authenticationService: makeAuthenticationService(),
                               messageService: makeMessagesService())
    }

    func makeLoginViewModel(loginRepository: LoginRepository,
                            user: OnBoardingUser = OnBoardingUser(accountType: .b2cAccount)) -> LoginViewModelType {
        return LoginViewModel(repository: loginRepository, credentialsManager: self.credentialsStore)
    }

    func makeLoginViewController(viewModel: LoginViewModelType) -> LoginViewController {
        return LoginViewController(themeService: self.themeService, viewModel: viewModel)
    }
}

extension YAPPakistanMainContainer {
    func makeBiometricsManager() -> BiometricsManager {
        return BiometricsManager()
    }

    func makeVerifyPasscodeViewController(isUserBlocked: Bool, onLogin: @escaping VerifyPasscodeViewModel.OnLoginClosure) -> VerifyPasscodeViewController {
        return VerifyPasscodeModuleBuilder(container: self, isUserBlocked: isUserBlocked, onLogin: onLogin).viewController()
    }

    func makePasscodeCoordinator(root: UINavigationController, isUserBlocked: Bool) -> PasscodeCoordinatorPushable  {
        return PasscodeCoordinatorPushable(container: self, root: root, isUserBlocked: isUserBlocked)
    }
}

extension YAPPakistanMainContainer {
    func makeOTPRepository() -> OTPRepositoryType {
        let messageService = makeMessagesService()
        let customerService = makeCustomersService()
        return OTPRepository(messageService: messageService, customerService: customerService)
    }

    func makeSessionProvider() -> SessionProviderType {
        return SessionProvider()
    }

    func makeLoginOTPVerificationViewModel(
        otpRepository: OTPRepositoryType,
        sessionProvider: SessionProviderType,
        userName: String,
        passcode: String,
        logo: UIImage? = UIImage(named: "icon_app_logo", in: .yapPakistan),
        headingKey: String = "screen_device_registration_otp_display_header_message",
        otpMessageKey: String = "screen_device_registration_otp_display_givn_text_message",
        onLogin: @escaping (Session, inout AccountProvider?, inout DemographicsRepositoryType?) -> Void
    ) -> LoginOTPVerificationViewModel {

        return LoginOTPVerificationViewModel(action: .deviceVerification,
                                             heading: headingKey.localized,
                                             subheading: String(format: otpMessageKey.localized,
                                                                userName.toFormatedPhoneNumber),
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

extension YAPPakistanMainContainer {
    func makeNotificationPermissionViewController() -> SystemPermissionViewController {
        return NotificationPermissionModuleBuilder(container: self).viewController()
    }

    func makeBiometricPermissionViewController() -> SystemPermissionViewController {
        return BiometricPermissionModuleBuilder(container: self).viewController()
    }
}
