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
        let viewModel = SetCardPinViewModel()
        return SetCardPinViewController(themeService: themeService, viewModel: viewModel)
    }
}

