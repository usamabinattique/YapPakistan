//
//  FPNewPinConfirmModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 12/12/2021.
//

import Foundation

struct FPNewPinConfirmModuleBuilder {
    let cardSerialNumber: String
    var passCode: String
    var newPin: String
    let container: UserSessionContainer

    func viewController() -> FPNewPinConfirmViewController {
        let themeService = container.themeService

        let strings = FPNewPinConfirmViewStrings(heading: "screen_confirm_card_pin_display_text_title".localized,
                                        agrement: "",
                                        terms: "",
                                                 next: "screen_confirm_card_pin_button_create_pin".localized)
        let repository = container.makeCardsRepository()

        let viewModel = FPNewPinConfirmViewModel(
            cardSerialNumber: cardSerialNumber,
            passCode: passCode,
            newPin: newPin,
            strings: strings,
            repository: repository)
        return FPNewPinConfirmViewController(themeService: themeService, viewModel: viewModel)
    }
}
