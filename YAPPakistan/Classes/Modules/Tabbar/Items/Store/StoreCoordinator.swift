//
//  StoreCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPCore

public class StoreCoordinator: Coordinator<ResultType<Void>> {

    private let root: UITabBarController
    private let result = PublishSubject<ResultType<Void>>()
    private var navigationRoot: UINavigationController!
    private let container: UserSessionContainer

    public init(root: UITabBarController, container: UserSessionContainer) {
        self.root = root
        self.container = container
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewModel = StoreViewModel()
        let viewController = StoreViewController(viewModel: viewModel, themeService: container.themeService)
        navigationRoot = UINavigationController(rootViewController: viewController)
        navigationRoot.navigationBar.isHidden = true
        navigationRoot.tabBarItem = UITabBarItem(title: "Store",
                                                 image: UIImage(named: "icon_tabbar_store", in: .yapPakistan),
                                                 selectedImage: nil)
        if root.viewControllers == nil {
            root.viewControllers = [navigationRoot]
        } else {
            root.viewControllers?.append(navigationRoot)
        }
        
        return result
    }
}

