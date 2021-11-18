//
//  SetCardPinModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/11/2021.
//

import Foundation

struct SetCardPinModuleBuilder {
    let cardSerialNumber: String
    let container: UserSessionContainer

    func viewController() -> SetCardPinViewController {
        let themeService = container.themeService

        let strings = SetCardPinViewStrings(heading: "screen_setpincode_title".localized,
                                            agrement: "",
                                            terms: "",
                                            next: "common_button_next".localized)
        let viewModel = SetCardPinViewModel(cardSerialNumber: cardSerialNumber, strings: strings, hideTermsView: true)
        return SetCardPinViewController(themeService: themeService, viewModel: viewModel)
    }
}
