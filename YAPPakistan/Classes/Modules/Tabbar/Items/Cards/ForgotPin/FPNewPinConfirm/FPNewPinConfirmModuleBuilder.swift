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

        let strings = FPNewPinConfirmViewStrings(heading: "Enter it one more time",
                                        agrement: "",
                                        terms: "",
                                        next: "Create PIN")
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
