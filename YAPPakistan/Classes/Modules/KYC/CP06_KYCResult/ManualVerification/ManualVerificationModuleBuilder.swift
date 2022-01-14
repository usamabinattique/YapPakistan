//
//  ManualVerificationModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 01/11/2021.
//

import Foundation

struct ManualVerificationModuleBuilder {
    let container: KYCFeatureContainer

    func viewController() -> ManualVerificationViewController {
        let themeService = container.themeService
        let viewModel = ManualVerificationViewModel()
        return ManualVerificationViewController(themeService: themeService, viewModel: viewModel)
    }
}
