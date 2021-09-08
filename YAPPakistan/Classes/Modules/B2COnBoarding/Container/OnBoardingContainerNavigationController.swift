//
//  OnBoardingContainerNavigationController.swift
//  YAP
//
//  Created by Zain on 01/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents

class OnBoardingContainerNavigationController: UINavigationController {
    
    var keyboardShown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if UIScreen.screenType != .iPhone5 {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        //}
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
