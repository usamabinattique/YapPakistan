//
//  AppDelegate.swift
//  YAPPakistan
//
//  Created by Tayyab Akram on 08/10/2021.
//  Copyright (c) 2021 Tayyab Akram. All rights reserved.
//

import UIKit
import RxSwift
import YAPCore

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
        window = UIWindow(frame: UIScreen.main.bounds)
        let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem
        appCoordinate(shortcutItem)
            .subscribe()
            .disposed(by: rx.disposeBag)
        
        return true
    }

}



