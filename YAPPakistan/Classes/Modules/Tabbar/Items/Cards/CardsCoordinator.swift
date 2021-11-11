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

        func testCardStatusVC() {
            let viewController = CardStatusViewController(themeService: self.container.themeService, viewModel: CardStatusViewModel())
            self.navigationRoot.pushViewController(viewController)
        }
        func testSetpinIntroVC() {
            let viewController = SetpinIntroModuleBuilder(container: self.container).viewController()
            self.navigationRoot.pushViewController(viewController)
        }
        func testSetpinSuccess() {
            let viewController = SetPintSuccessModuleBuilder(container: self.container).viewController()
            self.navigationRoot.pushViewController(viewController)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { testCardStatusVC() })
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: { testSetpinIntroVC() })
        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: { testSetpinSuccess() })
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewController = CardsViewController(viewModel: CardsViewModel())
        navigationRoot = UINavigationController(rootViewController: viewController)
        navigationRoot.navigationBar.isHidden = true
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
}

