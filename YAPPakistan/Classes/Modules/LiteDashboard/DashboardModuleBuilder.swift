//
//  DashboardModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation
struct DashboardModuleBuilder {
    let container: UserSessionContainer

    func viewController() -> LiteDashboardViewController {

        let notificationManager = container.parent.makeNotificationManager()

        let viewModel = LiteDashboardViewModel(accountProvider: container.accountProvider,
                                               biometricsManager: container.biometricsManager,
                                               notificationManager: notificationManager,
                                               credentialStore: container.parent.credentialsStore,
                                               repository: container.makeLoginRepository())
        let viewController = LiteDashboardViewController(themeService: container.parent.themeService,
                                                         viewModel: viewModel)

        return viewController
    }
}
