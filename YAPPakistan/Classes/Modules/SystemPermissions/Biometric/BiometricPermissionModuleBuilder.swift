//
//  BiometricPermissionModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 05/10/2021.
//

import Foundation

struct BiometricPermissionModuleBuilder {
    let container: YAPPakistanMainContainer

    func viewController() -> SystemPermissionViewController {

        let biometricsManager = container.makeBiometricsManager()
        let permissionType: SystemPermissionType = biometricsManager.deviceBiometryType == .faceID ? .faceID : .touchID
        let phone = container.credentialsStore.getUsername() ?? ""

        let viewModel = BiometricPermissionViewModel(permissionType: permissionType,
                                                     biometricsManager: biometricsManager, phone: phone)

        return SystemPermissionViewController(themeService: container.themeService, viewModel: viewModel)
    }
}
