//
//  WaitingListRankCoordinator.swift
//  YAPPakistan
//
//  Created by Tayyab on 23/09/2021.
//

import Foundation
import RxSwift
import YAPCore

class WaitingListRankCoordinator: Coordinator<ResultType<Void>> {
    private let container: UserSessionContainer
    private let window: UIWindow

    private let resultSubject = PublishSubject<ResultType<Void>>()
    private var root: UINavigationController!

    init(container: UserSessionContainer, window: UIWindow) {
        self.container = container
        self.window = window
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewController = container.makeWaitingListController()

        root = UINavigationController(rootViewController: viewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true

        window.rootViewController = root
        window.makeKeyAndVisible()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)

        return resultSubject
    }
}
