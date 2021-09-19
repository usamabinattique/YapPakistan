//
//  ReachedQueueTopCoordinator.swift
//  YAPPakistan
//
//  Created by Tayyab on 16/09/2021.
//

import Foundation
import RxSwift
import YAPCore

class ReachedQueueTopCoordinator: Coordinator<ResultType<Void>> {
    private let container: YAPPakistanMainContainer
    private let window: UIWindow?

    private let resultSubject = PublishSubject<ResultType<Void>>()
    private var root: UINavigationController!

    init(container: YAPPakistanMainContainer, window: UIWindow) {
        self.container = container
        self.window = window
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewController = container.makeReachedQueueTopViewController()

        root = UINavigationController(rootViewController: viewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true

        self.window?.rootViewController = self.root

        return resultSubject
    }
}
