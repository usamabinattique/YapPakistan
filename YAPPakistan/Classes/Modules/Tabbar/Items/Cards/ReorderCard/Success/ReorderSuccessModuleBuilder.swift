//
//  ReorderSuccessModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 29/12/2021.
//

import Foundation

struct ReorderSuccessModuleBuilder {

    let container: UserSessionContainer

    func viewController() -> ReorderSuccessViewController {
        let themeService = container.themeService
        let viewModel = ReorderSuccessViewModel()
        return ReorderSuccessViewController(themeService: themeService, viewModel: viewModel)
    }
}
