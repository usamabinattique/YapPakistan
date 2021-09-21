//
//  LiteDashboardCoordinator.swift
//  YAP
//
//  Created by Wajahat Hassan on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import YAPCore

class LiteDashboardCoodinator: Coordinator<ResultType<Void>> {
    private let container: UserSessionContainer
    private let window: UIWindow
    private let result = PublishSubject<ResultType<Void>>()
    private var root: UINavigationController!

    private let disposeBag = DisposeBag()

    init(container: UserSessionContainer, window: UIWindow) {
        self.container = container
        self.window = window
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewController = container.makeLiteDashboardViewController()
        let viewModel: LiteDashboardViewModelType = viewController.viewModel

        root = UINavigationController(rootViewController: viewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true

        window.rootViewController = root
        window.makeKeyAndVisible()
        
        viewModel.outputs.result.subscribe(onNext: { [weak self] in
            self?.result.onNext(ResultType.success($0))
            self?.result.onCompleted()
        }).disposed(by: disposeBag)

        viewModel.outputs.completeVerification.subscribe(onNext: { [weak self] in
            // FIXME: Navigate to verification flow.
        }).disposed(by: disposeBag)

        return result
    }
}
