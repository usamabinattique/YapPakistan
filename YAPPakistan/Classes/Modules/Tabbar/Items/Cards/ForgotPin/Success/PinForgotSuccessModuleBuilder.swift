//
//  13.swift
//  YAPPakistan
//
//  Created by Sarmad on 12/12/2021.
//

import Foundation

struct PinForgotSuccessModuleBuilder {
    let container: UserSessionContainer

    func viewController() -> PinForgotSuccessViewController {
        let themeService = container.themeService
        let viewModel = PinForgotSuccessViewModel()
        return PinForgotSuccessViewController(themeService: themeService, viewModel: viewModel)
    }
}
