//
//  BiometricPermissionViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 05/10/2021.
//

import Foundation

class BiometricPermissionViewModel: SystemPermissionViewModel {

    init(permissionType: SystemPermissionType,
         biometricsManager: BiometricsManager,
         phone: String) {

        super.init(permissionType: permissionType) {
            biometricsManager.setBiometryPermission(isPrompt: true, phone: phone)
        } setPermissonCompletion: {
            biometricsManager.setBiometry(isEnabled: true, phone: phone)
        }
    }
}
