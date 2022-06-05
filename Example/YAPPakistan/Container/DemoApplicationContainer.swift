//
//  SelectCountry.swift
//  YAPPakistan_Example
//
//  Created by Umer on 04/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import YAPCore
import YAPPakistan
import RxTheme

final class DemoApplicationContainer {
    let store: CredentialsStoreType
    let themeService: ThemeService<AppTheme>
    let featureFlagProvider: RemoteFallBackToLocalProvider!
    let countryListProvider: CountryListProviderType
    
    private lazy var yapPakistanContainer: YAPPakistanMainContainer  =  {
        YAPPakistanMainContainer(configuration: YAPPakistanConfiguration(environment: .current, googleMapsAPIKey: "AIzaSyCy_1KJ3iHy2SSQDo3Q35YS96vNDx4xZuI", callback: eventCallback))
    }()

    init(store: CredentialsStoreType) {
        self.store = store
        // setup feature flag provider
        let jsonFileURL = Bundle.main.url(forResource: "DefaultFeatureFlags", withExtension: "json")!
        let handler = FeatureFlagFileManager()
        let remoteProvider = RemoteFeatureFlagProvider(databaseHandler: handler)
        let localProvider = LocalFeatureFlagProvider(databaseHandler: handler)
        let defaultProvider = DefaultFeatureFlagProvider(jsonUrl: jsonFileURL)
        featureFlagProvider = RemoteFallBackToLocalProvider(localProvider: localProvider,
                                                            remoteProvider: remoteProvider,
                                                            defaultProvider: defaultProvider)
        countryListProvider = CountryListProvider(featureFlagProvider: featureFlagProvider)
        self.themeService = AppTheme.service(initial: .light)
        //yapPakistanContainer = YAPPakistanMainContainer(configuration: YAPPakistanConfiguration(environment: .current))
    }
}

// Coordinator
extension DemoApplicationContainer {
    func makeOnBoardingCoodinator(window: UIWindow) -> B2COnBoardingCoordinator  {
        B2COnBoardingCoordinator(container: self, window: window)
    }

    func makeSplashCoordinator(window: UIWindow) -> SplashCoordinator {
        SplashCoordinator(window: window, shortcutItem: nil, store: store)
    }

    func makeWelcomeCoordinator(window: UIWindow) -> WelcomeCoordinator {
        WelcomeCoordinator(container: self, window: window)
    }

    func makeLoginCoordinator(window: UIWindow) -> LoginCoordinator {
        LoginCoordinator(window: window, container: self)
    }

    func makePKAppCoordinator(window: UIWindow,
                              navigationController: UINavigationController,
                              formattedPhoneNumber: String?,
                              onboarding: Bool) -> YAPPakistan.AppCoordinator {
        let flow = onboarding ? YAPPakistan.Flow.onboarding(formattedPhoneNumber: formattedPhoneNumber ?? "")
            : YAPPakistan.Flow.passcode(formattedPhoneNumber: formattedPhoneNumber ?? "")
        return yapPakistanContainer.rootCoordinator(window: window,
                                             navigationController: navigationController,
                                             flow: flow)
    }
}

// Controllers
extension DemoApplicationContainer {
    func makePhoneNumberViewController(user: OnBoardingUser) -> PhoneNumberViewController {
        let phoneNumberViewModel = PhoneNumberViewModel(repositoryProvider: onBoardingRepositoryProvider,
                                                        user: user,
                                                        countryListProvider: countryListProvider)
        return PhoneNumberViewController(themeService: themeService, viewModel: phoneNumberViewModel)
    }

    func makeWelcomeViewController() -> WelcomeViewController {
        let viewModel = WelcomeViewModel()
        return WelcomeViewController(themeService: themeService, viewModel: viewModel)
    }

    func makeLoginViewController() -> LoginViewController {
        let viewModel = LoginViewModel(repositoryProvider: loginRepositoryProvider,
                                       credentialsManager: store,
                                       countryListProvider: countryListProvider)
        return LoginViewController(themeService: themeService, viewModel: viewModel)
    }
    
//    func makeFundTransferViewController() -> {
//        
//    }
}

// Providers
extension DemoApplicationContainer {

    func loginRepositoryProvider(_ countryCode: String) -> LoginRepositoryType {
        if countryCode == "PK" {
            return yapPakistanContainer.makeLoginRepository()
        }
        return yapPakistanContainer.makeLoginRepository()
    }

    func onBoardingRepositoryProvider(_ countryCode: String) -> OnBoardingRepositoryType {
        if countryCode == "PK" {
            return yapPakistanContainer.makeOnBoardingRepository()
        }
        return yapPakistanContainer.makeOnBoardingRepository()
    }

}


