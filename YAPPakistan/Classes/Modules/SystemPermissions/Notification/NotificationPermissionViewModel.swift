//
//  NotificationPermissionViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 05/10/2021.
//

import Foundation

class NotificationPermissionViewModel: SystemPermissionViewModel {

    init(permissionType: SystemPermissionType,
         notificationManager: NotificationManager) {

        super.init(permissionType: permissionType) {
            notificationManager.setNotificationPermission(isPrompt: true)
        } setPermissonCompletion: {
            notificationManager.registerForPushNotifications()
        }
    }
}
