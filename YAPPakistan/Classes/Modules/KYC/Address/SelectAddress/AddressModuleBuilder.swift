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
        let locationService = LocationService()
        let kycRepository = container.makeKYCRepository()
        let viewModel = AddressViewModel(locationService: locationService,
                                         kycRepository: kycRepository,
                                         accountProvider: container.accountProvider )
        return AddressViewController(themeService: themeService, viewModel: viewModel)
    }
}
