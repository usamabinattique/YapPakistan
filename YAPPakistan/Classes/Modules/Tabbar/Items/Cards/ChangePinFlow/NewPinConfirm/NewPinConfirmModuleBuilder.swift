//
//  NewPinConfirmModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/12/2021.
//

import Foundation

struct NewPinConfirmModuleBuilder {
    let cardSerialNumber: String
    let oldPin: String
    let newPin: String
    let container: UserSessionContainer

    func viewController() -> NewPinConfirmViewController {
        let themeService = container.themeService

        let strings = NewPinConfirmViewStrings(heading: "screen_confirm_card_pin_display_text_title".localized,
                                               agrement: "",
                                               terms: "",
                                                        next: "screen_confirm_card_pin_button_create_pin".localized)
        let viewModel = NewPinConfirmViewModel(cardSerialNumber: cardSerialNumber, oldPin: oldPin,
                                               newPin: newPin, strings: strings,
                                               repository: container.makeCardsRepository())
        return NewPinConfirmViewController(themeService: themeService, viewModel: viewModel)
    }
}
