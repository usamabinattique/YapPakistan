//
//  AccountOpenSuccessModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 01/11/2021.
//

import Foundation

struct AccountOpenSuccessModuleBuilder {
    let container: KYCFeatureContainer

    func viewController() -> AccountOpenSuccessViewController {
        let themeService = container.themeService
        let viewModel = AccountOpenSuccessViewModel()
        return AccountOpenSuccessViewController(themeService: themeService, viewModel: viewModel)
    }
}
