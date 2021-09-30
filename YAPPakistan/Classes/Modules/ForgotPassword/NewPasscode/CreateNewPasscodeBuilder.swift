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

        let strings = PasscodeViewStrings(
            heading: "screen_create_passcode_display_text_title".localized,
            agrement: "screen_create_passcode_display_text_terms_and_conditions".localized,
            terms: "screen_create_passcode_display_button_terms_and_conditions".localized,
            action: "screen_create_passcode_button_create_new_passcode".localized
        )
        let pinRange: ClosedRange<Int> = 4...6

        let viewModel = CreateNewPasscodeViewModel(repository: pinRepository,
                                                   credentialsManager: container.credentialsStore,
                                                   username: username,
                                                   token: token,
                                                   passcodeViewStrings: strings,
                                                   pinRange: pinRange)
        
        return PasscodeViewController(themeService: container.themeService, viewModel: viewModel)
    }
}
