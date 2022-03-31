//
//  MoreCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPCore

public class MoreCoordinator: Coordinator<ResultType<Void>> {

    private let root: UITabBarController
    private let result = PublishSubject<ResultType<Void>>()
    private var navigationRoot: UINavigationController!
    private var container: UserSessionContainer!

    public init(root: UITabBarController, container: UserSessionContainer) {
        self.root = root
        self.container = container
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = MoreBankDetailsViewModel(accountProvider: container.accountProvider)
        let viewController = MoreBankDetailsViewController(themeService: container.themeService, viewModel: viewModel)
//        self.localRoot.pushViewController(viewController, completion: nil)
        
        
//        let viewController = MoreViewController(viewModel: MoreViewModel())
        navigationRoot = UINavigationController(rootViewController: viewController)
        navigationRoot.navigationBar.isHidden = true
        navigationRoot.tabBarItem = UITabBarItem(title: "More",
                                                 image: UIImage(named: "icon_tabbar_more", in: .yapPakistan),
                                                 selectedImage: nil)

        if root.viewControllers == nil {
            root.viewControllers = [navigationRoot]
        } else {
            root.viewControllers?.append(navigationRoot)
        }

        return result
    }
}

