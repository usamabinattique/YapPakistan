//
//  CardOnItsWayModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 01/11/2021.
//

import Foundation

struct CardOnItsWayModuleBuilder {
    let container: KYCFeatureContainer

    func viewController() -> CardOnItsWayViewController {
        let themeService = container.themeService
        let viewModel = CardOnItsWayViewModel()
        return CardOnItsWayViewController(themeService: themeService, viewModel: viewModel)
    }
}
