//
//  NotificationManager.swift
//  YAPKit
//
//  Created by Hussaan S on 09/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public class NotificationManager {
    
    
    public static let shared = NotificationManager()
    
    public var isChangingSystemSettings = false
    
    public var isSystemAuthorised = false
    
    private init() {}
    
    public var isNotificationPermissionPrompt: Bool {
        return  UserDefaults.standard.bool(forKey: "USER_DEFAULTS_KEY_NOTIFICATION_PERMISSION_PROMPT")
    }
    
    public func setNotificationPermission(isPrompt: Bool) {
        UserDefaults.standard.set(isPrompt, forKey: "USER_DEFAULTS_KEY_NOTIFICATION_PERMISSION_PROMPT")
    }
    
    public func turnNotificationsOn(){
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                YAPUserDefaults.turnNotificationOn(preference: true)
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            else {
                DispatchQueue.main.async {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            NotificationManager.shared.isChangingSystemSettings = success
                        })
                    }
                }
            }
        }
    }
    
    public func isNotificationAuthorised()-> Bool {
        return isSystemAuthorised && YAPUserDefaults.isNotificationOn()
    }
        
    
   public func turnNotificationsOff() {
        DispatchQueue.main.async {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
        YAPUserDefaults.turnNotificationOn(preference: false)
    }
    
    public func observeChangeInSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                YAPUserDefaults.turnNotificationOn(preference: true)
                NotificationCenter.default.post(Notification(name: .checkUserNotificationPreference))
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            else {
                YAPUserDefaults.turnNotificationOn(preference: false)
            }
        }
    }
    
    func setupNotificationPreference() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                NotificationManager.shared.isChangingSystemSettings = false
                return }
            NotificationManager.shared.isChangingSystemSettings = true
        }
    }
}
