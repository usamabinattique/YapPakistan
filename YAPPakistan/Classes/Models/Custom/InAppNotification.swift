//
//  InAppNotification.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import Foundation
//import Leanplum

public enum InAppNotificationType {
    case operational
    case transactional
    case marketing
}

public enum InAppNotificationAction {
    case kycAmendment
    case completeVerification
    case setPin
    case updateEmiratesId
    case householdInvitation
    case helpAndSupport
    case callHelpLine
    case liveSupport
    case none
}

public extension InAppNotificationAction {
    var actionTitle: String? {
        switch self {
        case .kycAmendment:
            return "Update information"
        case .completeVerification:
            return "Complete verification"
        case .setPin:
            return "Set PIN now"
        case .updateEmiratesId:
            return "Scan Emirates ID"
        case .householdInvitation:
            return "Accept invitations"
        case .helpAndSupport:
            return "Open Help & Support"
        case .callHelpLine:
            return "Call us"
        case .liveSupport :
             return "Open Live Support"
        case .none:
            return nil
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .helpAndSupport, .callHelpLine:
            return UIImage.sharedImage(named: "icon_notification_general")
        case .kycAmendment:
            return UIImage.sharedImage(named: "icon_kyc_amendment")
        case .completeVerification, .updateEmiratesId:
            return UIImage.sharedImage(named: "icon_notification_documents")
        case .setPin:
            return UIImage.sharedImage(named: "icon_notification_setpin")
        default:
            return UIImage.sharedImage(named: "icon_notification_general")
        }
    }
}

public struct InAppNotification {
    public let id: String?
    public let title: String?
    public let description: String?
    public let deletable: Bool
    public let date: Date?
    public let imageUrl: String?
    public let readStatus: Bool
    public let action: InAppNotificationAction?
    public let notificationType: InAppNotificationType
}
/*
public extension InAppNotification {
    init(notification: TransactionNotification) {
        self.id = notification.notificationId
        self.title = notification.title
        self.description = notification.notificationText
        self.deletable = notification.isDeleteable
        self.date = DateFormatter.serverReadableDateFromatter.date(from: notification.transactionDate ?? "")
        self.imageUrl = notification.profilePicUrl
        self.readStatus = notification.isRead
        self.action = InAppNotificationAction.none
        self.notificationType = .transactional
    }
    
    init(notification: LeanplumInbox.Message) {
        self.id = notification.messageId
        self.title = notification.title
        self.description = notification.subtitle
        self.deletable = true
        if let date = notification.deliveryTimestamp {
            let dateString = DateFormatter.serverReadableDateFromatter.string(from: date)
            self.date = DateFormatter.serverReadableDateFromatter.date(from: dateString)
        }else {
            self.date = nil
        }
        self.imageUrl = notification.imageURL?.absoluteString
        self.readStatus = notification.isRead
        self.action = InAppNotificationAction.none
        self.notificationType = .marketing
    }
    
}

public extension InAppNotification {
    var imageWithUrl: ImageWithURL {
        (imageUrl, title?.initialsImage(color: .primary))
    }
    
    var userReadableDate: String? {
        date?.userReadableDateString
    }
} */

extension InAppNotification: Comparable {
    public static func < (lhs: InAppNotification, rhs: InAppNotification) -> Bool {
        
        if let lDate = lhs.date , let rDate =  rhs.date , lDate < rDate {
            return true
        } else { return false }
    }
}
