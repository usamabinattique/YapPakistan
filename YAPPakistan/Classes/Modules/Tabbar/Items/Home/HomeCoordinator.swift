//
//  HomeCoordinator.swift
//  YAP
//
//  Created by Muhammad Hussaan Saeed on 26/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import RxSwift
import YAPCore

public class HomeCoordinator: Coordinator<ResultType<Void>> {

    private let root: UITabBarController
    private let result = PublishSubject<ResultType<Void>>()
    private var navigationRoot: UINavigationController!
    
    public init(root: UITabBarController) {
        self.root = root
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewController = HomeViewController(viewModel: HomeViewModel())
        navigationRoot = UINavigationController(rootViewController: viewController)
        navigationRoot.navigationBar.isHidden = true
        navigationRoot.tabBarItem = UITabBarItem(title: "Home",
                                                 image: UIImage(named: "icon_tabbar_home", in: .yapPakistan),
                                                 selectedImage: nil)

        if root.viewControllers == nil {
            root.viewControllers = [navigationRoot]
        } else {
            root.viewControllers?.append(navigationRoot)
        }

        return result
    }
}
