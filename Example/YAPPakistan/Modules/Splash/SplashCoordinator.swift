//
//  SplashCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/08/2021.
//

import RxSwift
import UIKit
import YAPCore

class SplashCoordinator: Coordinator<ResultType<NavigationType>> {
    
    private var root: UINavigationController!
    private var window: UIWindow
    
    private let shortcutItem: UIApplicationShortcutItem?
    private let credentialsStore: CredentialsStoreType
    
    init(window: UIWindow,
         shortcutItem: UIApplicationShortcutItem?,
         store: CredentialsStoreType) {
        self.window = window
        self.shortcutItem = shortcutItem
        self.credentialsStore = store
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<NavigationType>> {
        let viewModel: SplashViewModelType = SplashViewModel(shortcutItem: shortcutItem,
                                                             credentialsStore: self.credentialsStore)
        let viewController = SplashViewController(viewModel: viewModel)
        
        root = UINavigationController(rootViewController: viewController)
        root.navigationBar.isHidden = true
        window.rootViewController = root
        window.makeKeyAndVisible()
        
        return viewModel.outputs.next.map { ResultType.success($0) }
    }
}

