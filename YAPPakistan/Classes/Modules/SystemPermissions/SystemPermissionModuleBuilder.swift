//
//  SystemPermissionModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 03/10/2021.
//

import Foundation

struct SystemPermissionModuleBuilder {
    let container: YAPPakistanMainContainer
    let permissionType:SystemPermissionType

    func viewController() -> SystemPermissionViewController {
        let strings = PasscodeSuccessViewStrings(
            heading: "screen_passcode_success_display_text_heading".localized,
            subHeading: "screen_passcode_success_display_text_sub_heading".localized,
            action: "common_button_Done".localized
        )

        let  notificationManager = NotificationManager()
        let viewModel = SystemPermissionViewModel(permissionType: permissionType,
                                                  account: nil,
                                                  notificationManager: notificationManager)
        return SystemPermissionViewController(themeService: container.themeService,
                                              viewModel: viewModel,
                                              notificationManager: notificationManager)
    }
}
