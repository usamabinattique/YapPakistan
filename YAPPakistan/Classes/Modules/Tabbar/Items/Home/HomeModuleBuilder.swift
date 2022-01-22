//
//  HomeModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation
struct HomeModuleBuilder {
    let container: UserSessionContainer

    func viewController() -> HomeViewController {

        let notificationManager = container.parent.makeNotificationManager()

        let viewModel = HomeViewModel(accountProvider: container.accountProvider,
                                               biometricsManager: container.biometricsManager,
                                               notificationManager: notificationManager,
                                               credentialStore: container.parent.credentialsStore,
                                               repository: container.makeLoginRepository())
        let viewController = HomeViewController(themeService: container.parent.themeService,
                                                         viewModel: viewModel)

        return viewController
    }
}