//
//  OnBoardingContainerNavigationController.swift
//  YAP
//
//  Created by Zain on 01/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxTheme
import RxSwift
import RxCocoa

class OnBoardingContainerNavigationController: UINavigationController {
    
    var keyboardShown: Bool = false
    fileprivate var themeService:ThemeService<AppTheme>!
    
    init(themeService:ThemeService<AppTheme>!, rootViewController: UIViewController) {
        self.themeService = themeService
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardDidShowNotification)
            .subscribe { [weak self] notif in
                self?.keyboardDidShow(notification: notif.element! as NSNotification)
            }.disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardDidHideNotification)
            .subscribe { [weak self] notif in
                self?.keyboardDidHide(notification: notif.element! as NSNotification)
            }.disposed(by: rx.disposeBag)
        
        setupTheme()
        
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ $0.backgroundColor }, to: [view.rx.backgroundColor])
    }
    
}

// MARK: Keyboard handling

fileprivate extension OnBoardingContainerNavigationController {
    
    @objc func keyboardDidShow(notification: NSNotification) {
        keyboardShown = true
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        keyboardShown = false
    }
}
