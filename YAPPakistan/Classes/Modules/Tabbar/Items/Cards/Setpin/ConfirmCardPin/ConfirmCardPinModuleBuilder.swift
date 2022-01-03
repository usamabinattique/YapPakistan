//
//  ConfirmCardPinModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 16/11/2021.
//

import Foundation

struct ConfirmCardPinModuleBuilder {
    let pinCode: String
    let cardSerialNumber: String
    let container: UserSessionContainer

    func viewController() -> ConfirmCardPinViewController {
        let cardsRepository = container.makeCardsRepository()
        let themeService = container.themeService

        let strings = ConfirmCardPinViewStrings(
            heading: "screen_setpincode_title_confirm".localized,
            agrement: "screen_setpincode_text_terms_and_conditions".localized,
            terms: "screen_setpincode_button_terms_and_conditions".localized,
            next: "screen_setpincode_craete".localized
        )

        let viewModel = ConfirmCardPinViewModel(cardsRepository: cardsRepository,
                                                pinCodeWillConfirm: pinCode,
                                                cardSerialNumber: cardSerialNumber,
                                                strings: strings,
                                                hideTermsView: false)
        return ConfirmCardPinViewController(themeService: themeService, viewModel: viewModel)
    }
}
