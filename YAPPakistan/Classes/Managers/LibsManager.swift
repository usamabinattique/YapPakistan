//
//  LibsManager.swift
//  iOSApp
//
//  Created by Abbas on 06/06/2021.
//


import Foundation
import RxSwift
import RxCocoa
//import IQKeyboardManagerSwift
//import NVActivityIndicatorView
//import RxViewController
import RxOptional
import RxGesture
import SwifterSwift
import RxTheme
//import Toast_Swift
//import Firebase
//import Kingfisher
//import KafkaRefresh

/// The manager class for configuring all libraries used in app.
class LibsManager: NSObject {

    /// Singleton instance.
    static let shared = LibsManager()


    private override init() { super.init() }

    func setupLibs(with window: UIWindow? = nil) {
        let libsManager = LibsManager.shared
        libsManager.setupTheme()
        //libsManager.setupKeyboardManager()
        //libsManager.setupToast()
        //libsManager.setupAnalytics()
        //libsManager.setupKingfisher()
        //libsManager.setupKafkaRefresh()
    }
    
    
    func setupTheme() {
        themeService.rx
            .bind({ $0.statusBarStyle }, to: UIApplication.shared.rx.statusBarStyle)
            .disposed(by: rx.disposeBag)
    
        //UIApplication.shared.theme.statusBarStyle = themed{ $0.statusBarStyle }
    }
    /*
    
    func setupToast() {
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.position = .top
        var style = ToastStyle()
        style.backgroundColor = UIColor.Material.red
        style.messageColor = UIColor.Material.white
        style.imageSize = CGSize(width: 20, height: 20)
        ToastManager.shared.style = style
    }
    
    func setupKafkaRefresh() {
        if let defaults = KafkaRefreshDefaults.standard() {
            defaults.headDefaultStyle = .replicatorAllen
            defaults.footDefaultStyle = .replicatorDot
            themeService.rx
                .bind({ $0.secondary }, to: defaults.rx.themeColor)
                .disposed(by: rx.disposeBag)
        }
    }

    func setupActivityView() {
        NVActivityIndicatorView.DEFAULT_TYPE = .ballRotateChase
        NVActivityIndicatorView.DEFAULT_COLOR = .secondary()
    }
 
    func setupKeyboardManager() {
        IQKeyboardManager.shared.enable = true
    }
    
    func setupKingfisher() {
        // Set maximum disk cache size for default cache. Default value is 0, which means no limit.
        ImageCache.default.diskStorage.config.sizeLimit = UInt(500 * 1024 * 1024) // 500 MB

        // Set longest time duration of the cache being stored in disk. Default value is 1 week
        ImageCache.default.diskStorage.config.expiration = .days(7) // 1 week

        // Set timeout duration for default image downloader. Default value is 15 sec.
        ImageDownloader.default.downloadTimeout = 15.0 // 15 sec
    }
    
    func setupAnalytics() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
    }
    */
}

