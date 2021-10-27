//
//  SelfieGuidelineModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation
struct SelfieGuidelineModuleBuilder {
    let container: KYCFeatureContainer

    func viewController() -> SelfieGuidelineViewController {
        let viewModel = SelfieGuidelineViewModel()
        return SelfieGuidelineViewController(themeService: container.themeService, viewModel: viewModel)
    }
}
