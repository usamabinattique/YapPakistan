//
//  VerifyPasscodeModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/10/2021.
//

import Foundation

struct VerifyPasscodeModuleBuilder {
    let container: YAPPakistanMainContainer
    let onLogin: VerifyPasscodeViewModel.OnLoginClosure

    func viewController() -> VerifyPasscodeViewController {

        let biometricsManager = container.makeBiometricsManager()
        let credentialsStore = container.credentialsStore
        let username = container.credentialsStore.getUsername() ?? ""
        let loginRepository = container.makeLoginRepository()
        let sessionProvider = SessionProvider(xsrfToken: container.xsrfToken)

        let viewModel = VerifyPasscodeViewModel(username:  username,
                                                isUserBlocked: false,
                                                repository: loginRepository,
                                                biometricsManager: biometricsManager,
                                                credentialsManager: credentialsStore,
                                                sessionCreator: sessionProvider,
                                                onLogin: onLogin)

        return VerifyPasscodeViewController(themeService: container.themeService,
                                            viewModel: viewModel,
                                            biometricsService: biometricsManager)
    }

}
