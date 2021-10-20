//
//  WelcomeCoordinator.swift
//  YAPPakistan_Example
//
//  Created by Umer on 13/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import YAPCore

enum WelcomeResult {
    case signin
    case signup
}

class WelcomeCoordinator: Coordinator<WelcomeResult> {
    private let container: DemoApplicationContainer
    public var root: UINavigationController!
    public var result = PublishSubject<WelcomeResult>()

    private let window: UIWindow

    init(container: DemoApplicationContainer,
         window: UIWindow) {
        self.container = container
        self.window = window
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<WelcomeResult> {
        
        let viewController = container.makeWelcomeViewController()
        let viewModel: WelcomeViewModelType = viewController.viewModel

        root = UINavigationController(rootViewController: viewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true

        self.window.rootViewController = self.root

        viewModel.outputs.personal.subscribe(onNext: {[unowned self] _ in
            self.result.onNext(.signup)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        viewModel.outputs.signIn.subscribe(onNext: { [unowned self] _ in
            self.result.onNext(.signin)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        return result
    }

    deinit {
        print("WelcomeCoordinator")
    }
    
}
