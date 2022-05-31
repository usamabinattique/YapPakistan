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
    private let container: UserSessionContainer
    private let window: UIWindow

    private let resultSubject = PublishSubject<ResultType<Void>>()
    private var root: UINavigationController!

    private let disposeBag = DisposeBag()

    init(container: UserSessionContainer, window: UIWindow) {
        self.container = container
        self.window = window
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewController = container.makeReachedQueueTopViewController()
        let viewModel = viewController.viewModel

        root = UINavigationController(rootViewController: viewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true

        window.rootViewController = root
        window.makeKeyAndVisible()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)

        viewModel?.outputs.success.subscribe(onNext: { [weak self] _ in
            self?.navigateToDashboard()
        }).disposed(by: disposeBag)

        return resultSubject
    }

    private func navigateToDashboard() {
        let window = root.view.window ?? UIWindow()
        let coordinator = TabbarCoodinator(container: container, window: window, showCompleteVerification: true)

        coordinate(to: coordinator).subscribe(onNext: { _ in
            self.resultSubject.onNext(ResultType.success(()))
            self.resultSubject.onCompleted()
        }).disposed(by: rx.disposeBag)
    }
}
