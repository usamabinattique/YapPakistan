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
        
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let referralManager = AppReferralManager(environment: .current)
        referralManager.parseReferralUrl(userActivity.webpageURL)

        return true
    }

    func configureAdjust() {
        let adjustAppToken = "pa4xup5ybrwg"

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
