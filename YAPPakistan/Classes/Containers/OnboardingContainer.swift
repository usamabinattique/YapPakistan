//
//  OnboardingContainer.swift
//  YAPPakistan
//
//  Created by Umer on 13/10/2021.
//

import Foundation

final class OnboardingContainer {
    let parent: YAPPakistanMainContainer
    private(set) var user: OnBoardingUser

    init(user: OnBoardingUser,
         parent: YAPPakistanMainContainer) {
        self.user = user
        self.parent = parent
    }

    func makeOnboardingCoordinator(navigationController: UINavigationController) -> B2COnBoardingCoordinator {
        B2COnBoardingCoordinator(container: self,
                                 navigationController: navigationController)
    }

    func makeEnterEmailController(user: OnBoardingUser) -> EnterEmailViewController {
        let sessionProvider = parent.makeSessionProvider()
        let onBoardingRepository = parent.makeOnBoardingRepository()
        
        let enterEmailViewModel = EnterEmailViewModel(
            credentialsStore: parent.credentialsStore,
            referralManager: parent.referralManager,
            sessionProvider: sessionProvider,
            onBoardingRepository: onBoardingRepository,
            user: user,
            analyticsTracker: self.parent.configuration.analytics!
        ) { session, accountProvider, onBoardingRepository, demographicsRepository in
            let sessionContainer = UserSessionContainer(parent: self.parent, session: session)
            accountProvider = sessionContainer.accountProvider
            onBoardingRepository = sessionContainer.makeOnBoardingRepository()
            demographicsRepository = sessionContainer.makeDemographicsRepository()
        }

        return EnterEmailViewController(themeService: parent.themeService, viewModel: enterEmailViewModel)
    }
}
