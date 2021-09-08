//
//  OnBoardinContainerChildViewController.swift
//  YAP
//
//  Created by Zain on 01/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import YAPComponents

class OnBoardinContainerChildViewController: UIViewController {
    
    var firstReponder: UITextField? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //if UIScreen.screenType != .iPhone5 {
        if (self.navigationController as? OnBoardingContainerNavigationController)?.keyboardShown ?? false {
            _ = firstReponder?.becomeFirstResponder()
        }
        //}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //if UIScreen.screenType != .iPhone5 {
        if !((self.navigationController as? OnBoardingContainerNavigationController)?.keyboardShown ?? false) {
            _ = firstReponder?.becomeFirstResponder()
        }
        //}
    }
}
