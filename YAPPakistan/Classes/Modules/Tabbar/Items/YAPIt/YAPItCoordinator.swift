//
//  File.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPCore

public class YAPItCoordinator: Coordinator<ResultType<Void>> {

    private let root: UITabBarController
    private let result = PublishSubject<ResultType<Void>>()
    private var navigationRoot: UINavigationController!

    public init(root: UITabBarController) {
        self.root = root
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewController = YAPItViewController(viewModel: YAPItViewModel())
        navigationRoot = UINavigationController(rootViewController: viewController)
        navigationRoot.navigationBar.isHidden = true
        navigationRoot.tabBarItem = UITabBarItem(title: "YAP it", image: nil, selectedImage: nil)

        if root.viewControllers == nil {
            root.viewControllers = [navigationRoot]
        } else {
            root.viewControllers?.append(navigationRoot)
        }

        return result
    }
}

