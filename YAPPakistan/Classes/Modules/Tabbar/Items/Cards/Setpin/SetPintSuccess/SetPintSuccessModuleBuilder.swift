//
//  SetPintSuccessModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/11/2021.
//

import Foundation

struct SetPintSuccessModuleBuilder {
    let container: UserSessionContainer

    func viewController() -> SetPintSuccessViewController {
        let themeService = container.themeService
        let viewModel = SetPintSuccessViewModel()
        return SetPintSuccessViewController(themeService: themeService, viewModel: viewModel)
    }
}

