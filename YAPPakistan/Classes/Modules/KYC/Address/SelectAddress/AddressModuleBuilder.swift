//
//  AddressModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation

struct AddressModuleBuilder {
    let container: KYCFeatureContainer

    func viewController() -> AddressViewController {
        let themeService = container.themeService
        let viewModel = AddressViewModel()
        return AddressViewController(themeService: themeService, viewModel: viewModel)
    }
}
