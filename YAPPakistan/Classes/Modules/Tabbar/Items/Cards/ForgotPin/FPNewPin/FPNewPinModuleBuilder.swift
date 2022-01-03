//
//  FPNewPinModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 12/12/2021.
//

import Foundation

struct FPNewPinModuleBuilder {
    let cardSerialNumber: String
    let container: UserSessionContainer

    func viewController() -> FPNewPinViewController {
        let themeService = container.themeService

        let strings = FPNewPinViewStrings(heading: "Enter your new 4-digit PIN code",
                                        agrement: "",
                                        terms: "",
                                        next: "common_button_next".localized)
        let viewModel = FPNewPinViewModel(cardSerialNumber: cardSerialNumber, strings: strings, hideTermsView: true)
        return FPNewPinViewController(themeService: themeService, viewModel: viewModel)
    }
}
