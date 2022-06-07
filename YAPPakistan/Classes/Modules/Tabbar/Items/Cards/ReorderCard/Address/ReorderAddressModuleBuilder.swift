//
//  ReorderAddressModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 29/12/2021.
//

import Foundation

struct ReorderAddressModuleBuilder {
    let container: KYCFeatureContainer

    func viewController() -> ReorderAddressViewController {
        let themeService = container.themeService
        let locationService = LocationService()
        let kycRepository = container.makeKYCRepository()
        let viewModel = ReorderAddressViewModel(locationService: locationService,
                                         kycRepository: kycRepository,
                                                accountProvider: container.accountProvider, configuration: container.mainContainer.configuration)
        return ReorderAddressViewController(themeService: themeService, viewModel: viewModel)
    }
}
