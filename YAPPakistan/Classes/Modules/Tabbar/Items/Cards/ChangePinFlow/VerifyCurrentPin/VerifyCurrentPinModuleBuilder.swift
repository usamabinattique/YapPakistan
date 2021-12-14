//
//  VerifyCurrentPinModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/12/2021.
//

import Foundation

struct VerifyCurrentPinModuleBuilder {
    let cardSerialNumber: String
    let container: UserSessionContainer

    func viewController() -> VerifyCurrentPinViewController {
        let themeService = container.themeService

        let strings = VerifyCurrentPinViewStrings(heading: "Enter your current PIN code",
                                            agrement: "",
                                            terms: "",
                                            next: "common_button_next".localized)
        let repository = container.makeCardsRepository()
        let viewModel = VerifyCurrentPinViewModel(cardSerialNumber: cardSerialNumber,
                                                  strings: strings,
                                                  repository: repository)
        return VerifyCurrentPinViewController(themeService: themeService, viewModel: viewModel)
    }
}
