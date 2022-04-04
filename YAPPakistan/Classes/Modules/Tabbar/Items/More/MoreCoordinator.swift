//
//  MoreCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPCore

public class MoreCoordinator: Coordinator<ResultType<UserProfileResult>> {

    private let root: UITabBarController
    private var navigationRoot: UINavigationController!
    private let result = PublishSubject<ResultType<UserProfileResult>>()
    private var container: UserSessionContainer!
    private let disposeBag = DisposeBag()
    
    public init(root: UITabBarController, container: UserSessionContainer) {
        self.root = root
        self.container = container
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<UserProfileResult>> {
        
//        let viewModel = MoreBankDetailsViewModel(accountProvider: container.accountProvider)
//        let viewController = MoreBankDetailsViewController(themeService: container.themeService, viewModel: viewModel)
//        self.localRoot.pushViewController(viewController, completion: nil)

        
        let viewModel = MoreViewModel(accountProvider: container.accountProvider, repository: container.makeMoreRepository(), theme: container.themeService)
        let viewController = MoreViewController(viewModel: viewModel, themeService: container.themeService)
        navigationRoot = UINavigationController(rootViewController: viewController)
        navigationRoot.navigationBar.isHidden = false
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
