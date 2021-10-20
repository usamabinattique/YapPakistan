//
//  LoginCoordinator.swift
//  YAPPakistan_Example
//
//  Created by Umer on 13/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore

enum LoginResult {
    case signup
    case passcode(formattedPhoneNumber: String)
    case cancel
}

class LoginCoordinator: Coordinator<LoginResult> {

    private var root: UINavigationController!
    private let container: DemoApplicationContainer
    private let result = PublishSubject<LoginResult>()
    private var window: UIWindow

    init(window: UIWindow,
         container: DemoApplicationContainer) {
        self.window = window
        self.container = container
    }

    deinit {
        print("LoginCoordinator")
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<LoginResult> {

        let loginViewController = container.makeLoginViewController()
        let viewModel: LoginViewModelType! = loginViewController.viewModel

        root = UINavigationController(rootViewController: loginViewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true

        self.window.rootViewController = self.root

        viewModel.outputs.signUp.subscribe(onNext: { [unowned self] in
            self.result.onNext(.signup)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        let logInResult = viewModel.outputs.result.share()

        logInResult.filter({ $0.isCancel }).subscribe(onNext: { [weak self] _ in
            self?.root.popViewController(animated: true)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        logInResult
            .filter({ $0.isSuccess != nil })
            .map({ $0.isSuccess })
            .unwrap()
            .subscribe(onNext: { [weak self] result in
                self?.result.onNext(LoginResult.passcode(formattedPhoneNumber: result.userName))
                self?.result.onCompleted()
            })
            .disposed(by: rx.disposeBag)

        return result
    }
}
