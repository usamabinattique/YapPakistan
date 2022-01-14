//
//  CaptureSelfieModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation

struct CaptureSelfieModuleBuilder {
    let container: KYCFeatureContainer

    func viewController() -> CaptureViewController {
        let themeService = container.themeService
        let viewModel = CaptureViewModel()
        return CaptureViewController(themeService: themeService, viewModel: viewModel)
    }
}
