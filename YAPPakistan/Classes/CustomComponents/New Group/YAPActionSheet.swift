//
//  YAPActionSheet.swift
//  YAPKit
//
//  Created by Zain on 03/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxTheme

public class YAPActionSheet {
    
    // MARK: Properties
    
    private let viewModel: YAPActionSheetViewModelType
    private let viewController: YAPActionSheetViewController
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    public init(title: String?, subTitle: String? = nil, bigIcon: Bool = false, themeService: ThemeService<AppTheme>) {
        viewModel = YAPActionSheetViewModel(title, subTitle, bigIcon: bigIcon)
        viewController = YAPActionSheetViewController(themeService: themeService, viewModel: viewModel)
    }
    
}

// MARK: Public methods

public extension YAPActionSheet {
    func addAction(_ action: YAPActionSheetAction) {
        viewModel.inputs.addActionObserver.onNext(action)
    }
    
    func show() {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        
        alertWindow.rootViewController = YAPActionSheetRootViewController(nibName: nil, bundle: nil)
        alertWindow.backgroundColor = .clear
        alertWindow.windowLevel = .alert + 1
        alertWindow.makeKeyAndVisible()
        
        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .overCurrentContext
        
        alertWindow.rootViewController?.present(nav, animated: false, completion: nil)
        
        viewController.window = alertWindow
    }
}

// MARK: Root View controller

public class YAPActionSheetRootViewController: UIViewController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIApplication.shared.statusBarStyle
        }
    }
}
