//
//  NotificationPermissionModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 03/10/2021.
//

import Foundation

struct NotificationPermissionModuleBuilder {
    let container: YAPPakistanMainContainer

    func viewController() -> SystemPermissionViewController {

        let notificationManager = NotificationManager()

        let viewModel = NotificationPermissionViewModel(permissionType: .notification,
                                                        notificationManager: notificationManager)

        return SystemPermissionViewController(themeService: container.themeService, viewModel: viewModel)
    }
}
