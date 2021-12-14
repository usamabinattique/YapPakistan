//
//  PinChangeSuccessModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/12/2021.
//

import Foundation

struct PinChangeSuccessModuleBuilder {
    let container: UserSessionContainer

    func viewController() -> PinChangeSuccessViewController {
        let themeService = container.themeService
        let viewModel = PinChangeSuccessViewModel()
        return PinChangeSuccessViewController(themeService: themeService, viewModel: viewModel)
    }
}

