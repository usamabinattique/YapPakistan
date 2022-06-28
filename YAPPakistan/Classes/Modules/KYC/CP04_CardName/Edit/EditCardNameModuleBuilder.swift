//
//  EditNameModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation

struct EditCardNameModuleBuilder {

    let container: UserSessionContainer

    func viewController(name: String) -> EditCardNameViewController {
        let themeService = container.themeService
        let viewModel = EditNameViewModel(name: name)

        return EditCardNameViewController(themeService: themeService, viewModel: viewModel)
    }
}
