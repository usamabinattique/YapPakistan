//
//  LoginCoordinatorReplaceable.swift
//  YAPPakistan
//
//  Created by Sarmad on 23/09/2021.
//

import Foundation
import RxSwift
import YAPCore

class LoginCoordinatorReplaceable: Coordinator<LoginResult>, LoginCoordinatorType {

    var root: UINavigationController!
    var window:UIWindow!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<LoginResult>()

    init(window: UIWindow,
         container: YAPPakistanMainContainer
    ){
        self.window = window
        self.container = container
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<LoginResult> {

        let viewModel = container.makeLoginViewModel(loginRepository: container.makeLoginRepository())
        let loginViewController = container.makeLoginViewController(viewModel: viewModel)

        root = UINavigationController(rootViewController: loginViewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true

        self.window.rootViewController = self.root

        viewModel.outputs.signUp.flatMapLatest({ [unowned self] _ in
            self.coordinate(to: WelcomeCoordinatorReplaceable(
                                container: container,
                                xsrfToken: container.mockToken,
                                window: window ))
        }).do(onNext: { [weak self] _ in
            self?.result.onCompleted()
        })
        .subscribe()
        .disposed(by: rx.disposeBag)

        let logInResult = viewModel.outputs.result.share()

        logInResult.filter({ $0.isSuccess != nil })
            .map({ $0.isSuccess })
            .unwrap()
            .subscribe(onNext: { [weak self] result in
                self?.navigateToPasscode(username: result.userName, isUserBlocked: result.isBlocked)
            })
            .disposed(by: rx.disposeBag)

        return result
    }

    func coordinateToWelcome() {
        coordinate(to: WelcomeCoordinatorReplaceable(
                    container: container,
                    xsrfToken: container.mockToken,
                    window: window ))
        .subscribe(onNext: { [weak self] _ in self?.result.onCompleted() })
        .disposed(by: rx.disposeBag)
    }

    func navigateToPasscode(username: String, isUserBlocked: Bool) {
        coordinate(to: container.makePasscodeCoordinator(root: root)).subscribe( onNext: { result in
            self.result.onNext(.cancel)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    }
}
