//
//  MenuItemType.swift
//  YAP
//
//  Created by Zain on 23/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import UIKit

public enum MenuItemType {
    case analytics
    case referFriend
    case young
    case housholdSalary
    case multicurrency
    case notifications
    case statements
    case contact
    case help
    case chat
    case locateATMCD
    case hosuseholdNotifications
    case qrCode
    case dashboardWidget
    case accountLimits
}

extension MenuItemType {
    var icon: UIImage? {
        switch self {
        case .analytics:
            return UIImage(named: "icon_menu_analytics", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .referFriend:
            return UIImage(named: "icon_menu_refer_friend", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .young:
            return UIImage(named: "icon_menu_young", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .housholdSalary:
            return UIImage(named: "icon_menu_household_salary", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .multicurrency:
            return UIImage(named: "icon_menu_multi_currency", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .notifications:
            return UIImage(named: "icon_menu_notifications", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .statements:
            return UIImage(named: "icon_menu_statements", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .contact:
            return UIImage(named: "icon_menu_contact", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .help:
            return UIImage(named: "icon_menu_help", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .locateATMCD:
            return UIImage(named: "icon_menu_help", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .hosuseholdNotifications:
            return UIImage(named: "icon_menu_notifications", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .chat:
            return UIImage(named: "icon_chat", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .qrCode:
            return UIImage(named: "icon_menu_qrcode", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .dashboardWidget:
            return UIImage(named: "icon_menu_widgets", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        case .accountLimits:
            return UIImage(named: "icon_menu_account_limits", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var title: String? {
        switch self {
        case .analytics:
            return "screen_menu_display_text_analytics".localized
        case .referFriend:
            return "screen_menu_display_text_refer_friend".localized
        case .young:
            return "screen_menu_display_text_yap_young".localized
        case .housholdSalary:
            return "screen_menu_display_text_household_salary".localized
        case .multicurrency:
            return "screen_menu_display_text_multi_currency".localized
        case .notifications:
            return "screen_menu_display_text_alert_and_notifications".localized
        case .statements:
            return "screen_menu_display_text_statements".localized
        case .contact:
            return "screen_menu_display_text_contact_us".localized
        case .help:
            return "screen_menu_display_text_help_and_support".localized
        case .locateATMCD:
            return "screen_menu_display_text_locate_atm_cd".localized
        case .hosuseholdNotifications:
            return "screen_menu_display_text_household_notification".localized
        case .chat:
            return "screen_menu_display_text_live_chat".localized
        case .qrCode:
            return "screen_menu_display_text_qr_code".localized
        case .dashboardWidget:
            return "screen_menu_display_text_dashboard_widget".localized
        case .accountLimits:
            return "screen_menu_display_text_account_limits".localized
        }
    }
    
    var color: UIColor? {
        switch self {
        case .analytics:
            return UIColor(hexString: "5E35B1")
        case .referFriend, .young, .housholdSalary, .multicurrency, .notifications, .statements, .contact, .help, .locateATMCD, .hosuseholdNotifications, .chat, .qrCode, .dashboardWidget, .accountLimits:
            return UIColor(hexString: "9391B1")
        }
    }
    
}
