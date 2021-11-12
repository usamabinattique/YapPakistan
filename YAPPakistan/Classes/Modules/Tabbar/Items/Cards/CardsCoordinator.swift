//
//  CardsCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPCore

public class CardsCoordinator: Coordinator<ResultType<Void>> {

    private let root: UITabBarController
    private let result = PublishSubject<ResultType<Void>>()
    private var navigationRoot: UINavigationController!
    private var container: UserSessionContainer!

    public init(root: UITabBarController, container: UserSessionContainer) {
        self.root = root
        self.container = container

        super.init()

        self.makeNavigationController()
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewController = CardsViewController(themeService: container.themeService, viewModel: CardsViewModel())
        navigationRoot.pushViewController(viewController, animated: false)
        navigationRoot.tabBarItem = UITabBarItem(title: "Cards",
                                                 image: UIImage(named: "icon_tabbar_cards", in: .yapPakistan),
                                                 selectedImage: nil)

        if root.viewControllers == nil {
            root.viewControllers = [navigationRoot]
        } else {
            root.viewControllers?.append(navigationRoot)
        }

        return result
    }

    func makeNavigationController() {
        navigationRoot = UINavigationController()
        navigationRoot.interactivePopGestureRecognizer?.isEnabled = false
        navigationRoot.navigationBar.isTranslucent = true
        navigationRoot.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationRoot.navigationBar.shadowImage = UIImage()
        navigationRoot.setNavigationBarHidden(false, animated: true)
    }
}

