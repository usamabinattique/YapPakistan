//
//  AppDelegate.swift
//  YAPPakistan
//
//  Created by Tayyab Akram on 08/10/2021.
//  Copyright (c) 2021 Tayyab Akram. All rights reserved.
//

import Adjust
import RxSwift
import UIKit
import YAPCore
import YAPPakistan

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: DemoAppCoordinator!

    // (Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPIKey") as? String) ?? ""
    
    fileprivate func appCoordinate(_ shortcutItem: UIApplicationShortcutItem? = nil) -> Observable<ResultType<Void>> {
        appCoordinator = DemoAppCoordinator(window: window!, shortcutItem: shortcutItem)
        return appCoordinator!.start().flatMap {[unowned self] _ in
            return self.appCoordinate()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureAdjust()

        window = UIWindow(frame: UIScreen.main.bounds)
        let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem
        appCoordinate(shortcutItem)
            .subscribe()
            .disposed(by: rx.disposeBag)

        registerNotification()
        return true
    }
    
    func registerNotification() {
        if #available(iOS 10.0, *) {
            // push notifications
            UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) {
                (granted, error) in
                if (granted) {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }

            let center  = UNUserNotificationCenter.current()
            //center.delegate = AppManager.appDel()
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let referralManager = AppReferralManager(environment: .current)
        referralManager.parseReferralUrl(userActivity.webpageURL)
        
        return true
    }

    func configureAdjust() {
        let adjustAppToken = AppConstants.Adjust.appToken

        var environment = ADJEnvironmentProduction
        #if DEBUG
        environment = ADJEnvironmentSandbox
        #endif

        guard let adjustConfig = ADJConfig(appToken: adjustAppToken, environment: environment) else { return }

        #if DEBUG
        adjustConfig.logLevel = ADJLogLevelVerbose
        #endif

        Adjust.appDidLaunch(adjustConfig)
    }
    
}

