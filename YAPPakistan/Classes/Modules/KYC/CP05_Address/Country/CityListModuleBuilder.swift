//
//  CountryListModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation
struct CityListModuleBuilder {
    let container: KYCFeatureContainer

    func viewController() -> CityListViewController {
        let kycRepository = container.makeKYCRepository()
        let themeService = container.themeService

        let viewModel = CityListViewModel(kycRepository: kycRepository)

        return CityListViewController(themeService: themeService, viewModel: viewModel)
    }
}
