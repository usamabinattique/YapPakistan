//
//  FPPassCodeModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 12/12/2021.
//

import Foundation

struct FPPassCodeModuleBuilder {
    let cardSerialNumber: String
    let container: UserSessionContainer

    func viewController() -> FPPassCodeViewController {
        let themeService = container.themeService

        let strings = FPPassCodeViewStrings(heading: "Enter your Passcode",
                                        agrement: "",
                                        terms: "",
                                        next: "common_button_next".localized)
        let repository = container.makeCardsRepository()
        let viewModel = FPPassCodeViewModel(strings: strings, repository: repository)
        return FPPassCodeViewController(themeService: themeService, viewModel: viewModel)
    }
}
