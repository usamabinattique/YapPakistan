//
//  ReviewSelfieModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation

struct ReviewSelfieModuleBuilder {
    let container: KYCFeatureContainer
    let image: UIImage

    func viewController() -> ReviewSelfieViewController {
        let kycRepository = container.makeKYCRepository()
        let accountProvider = container.accountProvider
        let viewModel = ReviewSelfieViewModel(image: image,
                                              kycRepository: kycRepository,
                                              accountProvider: accountProvider)
        return ReviewSelfieViewController(themeService: container.themeService, viewModel: viewModel)
    }
}
