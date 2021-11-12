//
//  SetCardPinModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/11/2021.
//

import Foundation

struct SetCardPinModuleBuilder {
    let container: UserSessionContainer

    func viewController() -> SetCardPinViewController {
        let themeService = container.themeService

        let localizeables = SetCardPinViewStrings(heading: "screen_setpincode_title_confirm".localized,
                                                  agrement: "screen_setpincode_text_terms_and_conditions".localized,
                                                  terms: "screen_setpincode_button_terms_and_conditions".localized,
                                                  action: "screen_setpincode_craete".localized)
        let viewModel = SetCardPinViewModel(localizeableKeys: localizeables)
        return SetCardPinViewController(themeService: themeService, viewModel: viewModel)
    }
}

