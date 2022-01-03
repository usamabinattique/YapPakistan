//
//  ChangeCardNameMobuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 12/12/2021.
//

import Foundation

struct  ChangeCardNameModuleBuilder {

    let container: UserSessionContainer
    let serialNumber: String
    let currentName: String
    let repository: CardsRepositoryType

    func viewController() -> ChangeCardNameViewController {
        let themeService = container.themeService
        let viewModel = ChangeCardNameViewModel(serialNumber: serialNumber,
                                                currentName: currentName,
                                                repository: repository)
        return ChangeCardNameViewController(themeService: themeService, viewModel: viewModel)
    }
}
