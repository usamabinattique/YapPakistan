//
//  NotificationManager.swift
//  YAPPakistan
//
//  Created by Sarmad on 27/09/2021.
//

import Foundation
import RxSwift

public protocol NotificationManagerType {
    var isNotificationPermissionPrompt: Bool { get }
    func setNotificationPermission(isPrompt: Bool)
    func deleteNotificationPermission()
    func turnNotificationsOn()
    func isNotificationAuthorised() -> Bool
    func turnNotificationsOff()
    func observeChangeInSettings()
}

public class NotificationManager: NotificationManagerType {

    fileprivate var deviceTokenSubject = PublishSubject<String?>()

    public var isChangingSystemSettings = false

    public var isSystemAuthorised = false

    public var isNotificationPermissionPrompt: Bool {
        return  UserDefaults.standard.bool(forKey: "USER_DEFAULTS_KEY_NOTIFICATION_PERMISSION_PROMPT")
    }

    public func setNotificationPermission(isPrompt: Bool) {
        UserDefaults.standard.set(isPrompt, forKey: "USER_DEFAULTS_KEY_NOTIFICATION_PERMISSION_PROMPT")
    }

    public func deleteNotificationPermission() {
        UserDefaults.standard.removeObject(forKey: "USER_DEFAULTS_KEY_NOTIFICATION_PERMISSION_PROMPT")
    }

    public func turnNotificationsOn(){
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                YAPUserDefaults.turnNotificationOn(preference: true)
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                DispatchQueue.main.async {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { success in
                            self.isChangingSystemSettings = success
                        })
                    }
                }
            }
        }
    }

    public func isNotificationAuthorised() -> Bool {
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
            } else {
                YAPUserDefaults.turnNotificationOn(preference: false)
            }
        }
    }

    func setupNotificationPreference() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                self.isChangingSystemSettings = false
                return }
            self.isChangingSystemSettings = true

        }
    }
}

extension NotificationManager {

    var deviceToken: Observable<String?> { return deviceTokenSubject.asObservable() }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            self.isSystemAuthorised = true
            DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
        }
    }

    public func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            _ = granted ? self?.turnNotificationsOn() : self?.turnNotificationsOff()
            guard let `self` = self else { return }
            guard granted else { return DispatchQueue.main.async { self.deviceTokenSubject.onNext(nil) }  }
            self.getNotificationSettings()
        }
    }

}
