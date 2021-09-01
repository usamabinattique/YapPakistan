//
//  AppDelegate.swift
//  YAPPakistan
//
//  Created by Tayyab Akram on 08/10/2021.
//  Copyright (c) 2021 Tayyab Akram. All rights reserved.
//

import UIKit
import YAPPakistan
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator:AppCoordinator!
    
    fileprivate func appCoordinate(_ shortcutItem: UIApplicationShortcutItem? = nil) -> Observable<ResultType<Void>> {
        appCoordinator = AppCoordinator(window: window!, shortcutItem: shortcutItem)
        return appCoordinator!.start().flatMap {[unowned self] _ in
            return self.appCoordinate()
        }
    }
    
    func testScreen() {
        
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        
        
        let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem
        appCoordinate(shortcutItem)
            .subscribe()
            .disposed(by: rx.disposeBag)
        
        return true
    }


}

