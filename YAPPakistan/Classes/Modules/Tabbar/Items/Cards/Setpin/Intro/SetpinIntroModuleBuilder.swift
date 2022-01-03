//
//  SetpinIntroModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 10/11/2021.
//

import Foundation

struct SetpinIntroModuleBuilder {
    let container: UserSessionContainer

    func viewController() -> SetpinIntroViewController {
        let themeService = container.themeService
        let viewModel = SetpinIntroViewModel()
        return SetpinIntroViewController(themeService: themeService, viewModel: viewModel)
    }
}

