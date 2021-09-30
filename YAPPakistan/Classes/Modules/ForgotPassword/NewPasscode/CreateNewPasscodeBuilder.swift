//
//  CreateNewPasscodeBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/09/2021.
//

import Foundation

struct CreateNewPasscodeBuilder {
    let container: YAPPakistanMainContainer
    let token: String

    func viewController() -> PasscodeViewController {
        let pinRepository = container.makePINRepository()
        let username = container.credentialsStore.getUsername() ?? ""
        let viewModel = CreateNewPasscodeViewModel(repository: pinRepository,
                                                   credentialsManager: container.credentialsStore,
                                                   username: username,
                                                   token: token)
        return PasscodeViewController(themeService: container.themeService, viewModel: viewModel)
    }
}
