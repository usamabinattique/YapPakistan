//
//  VerifyPasscodeModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/10/2021.
//

import Foundation

struct VerifyPasscodeModuleBuilder {
    let container: YAPPakistanMainContainer
    let isUserBlocked: Bool
    let onLogin: VerifyPasscodeViewModel.OnLoginClosure

    func viewController() -> VerifyPasscodeViewController {
        let biometricsManager = container.makeBiometricsManager()
        let credentialsStore = container.credentialsStore
        let username = container.credentialsStore.getUsername() ?? ""
        let loginRepository = container.makeLoginRepository()
        let sessionProvider = container.makeSessionProvider()
        let notificationManager = container.makeNotificationManager()

        let viewModel = VerifyPasscodeViewModel(username: username,
                                                isUserBlocked: isUserBlocked,
                                                repository: loginRepository,
                                                biometricsManager: biometricsManager,
                                                credentialsManager: credentialsStore,
                                                notificationManager: notificationManager,
                                                sessionCreator: sessionProvider,
                                                onLogin: onLogin)

        return VerifyPasscodeViewController(themeService: container.themeService,
                                            viewModel: viewModel,
                                            biometricsService: biometricsManager)
    }
}
