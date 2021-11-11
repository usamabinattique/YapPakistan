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
        let pinRange = 4...4
        let localizeables = SetCardPinViewStrings(heading: "".localized,
                                                  agrement: "".localized,
                                                  terms: "".localized,
                                                  action: "".localized)
        let viewModel = SetCardPinViewModel(pinRange: pinRange,  localizeableKeys: localizeables)
        return SetCardPinViewController(themeService: themeService, viewModel: viewModel)
    }
}

