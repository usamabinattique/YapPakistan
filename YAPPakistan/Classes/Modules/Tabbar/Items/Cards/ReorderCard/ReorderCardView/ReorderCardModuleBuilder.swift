//
//  ReorderCardModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 25/12/2021.
//

import Foundation

struct ReorderCardModuleBuilder {
    
    let container: UserSessionContainer
    let serialNumber: String
    let repository: CardsRepositoryType
    
    func viewController() -> ReorderCardViewController {
        let themeService = container.themeService
        let viewModel = ReorderCardViewModel(serialNumber: serialNumber,
                                             repository: repository)
        return ReorderCardViewController(themeService: themeService, viewModel: viewModel)
    }
}
