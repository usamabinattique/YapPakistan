//
//  SystemPermissionType.swift
//  YAPPakistan
//
//  Created by Sarmad on 04/10/2021.
//

import Foundation

enum SystemPermissionType {
    case faceID, touchID, notification
}

extension SystemPermissionType {
    var name: String {
        switch self {
        case .faceID: return "Face ID"
        case .touchID:  return "Touch ID"
        case .notification: return "notification"
        }
    }
}

extension SystemPermissionType {
    var strings: SystemPermissionStrings {
        switch self {
        case .faceID: return SystemPermissionStrings(
            "screen_system_permission_text_title_face_id".localized,
            "screen_system_permission_text_details_face_id".localized,
            (String(format: "screen_system_permission_text_title_terms_and_conditions".localized, self.name)),
            "screen_system_permission_text_terms_and_conditions".localized,
            (String(format: "screen_system_permission_button_touch_id".localized, self.name)) )
        case .touchID: return SystemPermissionStrings(
            "screen_system_permission_text_title_touch_id".localized,
            "screen_system_permission_text_details_touch_id".localized,
            (String(format: "screen_system_permission_text_title_terms_and_conditions".localized, "Touch ID")),
            "screen_system_permission_text_terms_and_conditions".localized,
            (String(format: "screen_system_permission_button_touch_id".localized, "Touch ID")) )
        case .notification: return SystemPermissionStrings(
            "screen_system_permission_text_title_notification".localized,
            "screen_system_permission_text_details_notification".localized,
            "",
            "",
            (String(format: "screen_notification_permission_button_title".localized, "notification")) )
        }
    }
}

extension SystemPermissionType {
    var icon:(name: String, isBackground: Bool) {
        switch self {
        case .faceID: return ("icon_face_id", false)
        case .touchID: return ("icon_touch_id", false)
        case .notification: return ("icon_notifications", true)
        }
    }
}

struct SystemPermissionStrings {
    let heading: String
    let subHeading: String
    let termsConditionDescription: String
    let termsConditionButtonTitle: String
    let buttonTitle: String
    init(_ heading: String,
         _ subHeading: String,
         _ termsConditionDescription: String,
         _ termsConditionButtonTitle: String,
         _ buttonTitle: String ) {

        self.heading = heading
        self.subHeading = subHeading
        self.termsConditionDescription = termsConditionDescription
        self.termsConditionButtonTitle = termsConditionButtonTitle
        self.buttonTitle = buttonTitle
    }
}
