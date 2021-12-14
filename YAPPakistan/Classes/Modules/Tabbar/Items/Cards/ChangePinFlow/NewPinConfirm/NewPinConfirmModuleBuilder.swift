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

        let strings = NewPinConfirmViewStrings(heading: "Enter it one more time",
                                               agrement: "",
                                               terms: "",
                                               next: "Create new PIN")
        let viewModel = NewPinConfirmViewModel(cardSerialNumber: cardSerialNumber, oldPin: oldPin,
                                               newPin: newPin, strings: strings,
                                               repository: container.makeCardsRepository())
        return NewPinConfirmViewController(themeService: themeService, viewModel: viewModel)
    }
}
