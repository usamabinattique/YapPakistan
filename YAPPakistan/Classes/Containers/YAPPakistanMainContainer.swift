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

public final class YAPPakistanMainContainer: CountryContainerType {
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

    public func makeNotificationManager() -> NotificationManager {
        return NotificationManager()
    }
    
    public func makeVerifyService() -> UserVerificationType {
        return PKUserVerificationService(loginRepository: makeLoginRepository(), onBoardRepository: makeOnBoardingRepository())
    }
    
    public func makeAppCoordinator(window: UIWindow, navigationController: UINavigationController, formattedNum: String, onboarding: Bool) -> Coordinator<ResultType<Void>> {
        let flow = onboarding ? Flow.onboarding(formattedPhoneNumber: formattedNum) : Flow.passcode(formattedPhoneNumber: formattedNum)
        return rootCoordinator(window: window, navigationController: navigationController, flow: flow)
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

    func makePasscodeCoordinatorReplaceable(window: UIWindow) -> PasscodeCoordinatorReplaceable {
        return PasscodeCoordinatorReplaceable(window: window, container: self, isUserBlocked: false)
    }
}

extension YAPPakistanMainContainer {
    public func makeLoginRepository() -> LoginRepository {
        return LoginRepository(customerService: self.makeCustomersService(),
                               authenticationService: makeAuthenticationService(),
                               messageService: makeMessagesService())
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

extension YAPPakistanMainContainer {
    func makeNavigationContainerController(
        navigation: UINavigationController = NavigationControllerBuilder().viewController()
    ) -> NavigationContainerViewController {
        NavigationContainerBuilder(navigation: navigation, container: self).viewController()
    }

    func makeNavigationController(
        root: UIViewController? = nil,
        isInteractivePopGesture: Bool = false,
        barBackgroundImage: UIImage = UIImage(),
        barShadowImage: UIImage = UIImage(),
        isBarTranslucent: Bool = true,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen
    ) -> UINavigationController {
        NavigationControllerBuilder(root: root,
                                    isInteractivePopGesture: isInteractivePopGesture,
                                    barBackgroundImage: barBackgroundImage,
                                    barShadowImage: barShadowImage,
                                    isBarTranslucent: isBarTranslucent,
                                    modalPresentationStyle: modalPresentationStyle).viewController()

    }
}

