//
//  SplashCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/08/2021.
//

//import YAPKit
import RxSwift
import UIKit
//import Authentication

class SplashCoordinator: Coordinator<ResultType<NavigationType>> {
    
    private var root: UINavigationController!
    private var window: UIWindow
    
    private let shortcutItem: UIApplicationShortcutItem?
    private let credentialsStore: CredentialsStoreType
    private let repository: SplashRepositoryType
    
    init(window: UIWindow,
         shortcutItem: UIApplicationShortcutItem?,
         store: CredentialsStoreType,
         repository: SplashRepositoryType) {
        self.window = window
        self.shortcutItem = shortcutItem
        self.credentialsStore = store
        self.repository = repository
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<NavigationType>> {
        let viewModel: SplashViewModelType = SplashViewModel(shortcutItem: shortcutItem,
                                                             credentialsStore: self.credentialsStore,
                                                             repository: self.repository)
        let viewController = SplashViewController(viewModel: viewModel)
        
        root = UINavigationController(rootViewController: viewController)
        root.navigationBar.isHidden = true
        window.rootViewController = root
        window.makeKeyAndVisible()
        
        return viewModel.outputs.next.map { ResultType.success($0) }
    }
}

