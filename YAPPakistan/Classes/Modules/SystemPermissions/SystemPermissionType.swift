//
//  SystemPermissionResourcesType.swift
//  YAPPakistan
//
//  Created by Sarmad on 04/10/2021.
//

import Foundation

protocol SystemPermissionResourcesType {
    var name: String { get }
    var iconName:String { get }
    var heading:String { get }
    var subHeading:String { get }
    var termsConditionDescription:String { get }
    var buttonTitle:String { get }
}

struct PermissionResources {
    struct FaceID: SystemPermissionResourcesType {
        var name = "Face ID"
        var iconName = "icon_face_id"
        var heading = "screen_system_permission_text_title_face_id"
        var subHeading = "screen_system_permission_text_details_face_id"
        var termsConditionDescription = "screen_system_permission_text_title_terms_and_conditions"
        var buttonTitle = "screen_system_permission_button_touch_id"
    }

    struct TouchID: SystemPermissionResourcesType {
        var name = "Touch ID"
        var iconName = "icon_touch_id"
        var heading = "screen_system_permission_text_title_touch_id"
        var subHeading = "screen_system_permission_text_details_touch_id"
        var termsConditionDescription = "screen_system_permission_text_title_terms_and_conditions"
        var buttonTitle = "screen_system_permission_button_touch_id"
    }

    struct Notification: SystemPermissionResourcesType {
        var name = "notification"
        var iconName = "icon_notifications"
        var heading = "screen_system_permission_text_title_notification"
        var subHeading = "screen_system_permission_text_details_notification"
        var termsConditionDescription = "screen_system_permission_text_title_terms_and_conditions"
        var buttonTitle = "screen_notification_permission_button_title"
    }
}
