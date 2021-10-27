//
//  EditNameModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation

struct EditCardNameModuleBuilder {

    let container: KYCFeatureContainer

    func viewController() -> EditCardNameViewController {
        let themeService = container.themeService
        let viewModel = EditNameViewModel()

        return EditCardNameViewController(themeService: themeService, viewModel: viewModel)
    }
}
