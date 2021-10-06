//
//  LoginCoordinatorPushable.swift
//  YAPPakistan
//
//  Created by Sarmad on 23/09/2021.
//

import Foundation
import RxSwift
import YAPCore

class LoginCoordinatorPushable: Coordinator<LoginResult>, LoginCoordinatorType {

    var root: UINavigationController!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<LoginResult>()

    init(root: UINavigationController,
         container: YAPPakistanMainContainer
    ){
        self.root = root
        self.container = container
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<LoginResult> {

        let viewModel = container.makeLoginViewModel(loginRepository: container.makeLoginRepository())
        let loginViewController = container.makeLoginViewController(viewModel: viewModel)

        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = false
        root.pushViewController(loginViewController, animated: true)

        viewModel.outputs.signUp.subscribe(onNext: { [unowned self] in
            if self.root.viewControllers.count > 1,
               self.root.viewControllers[self.root.viewControllers.count - 2] is WelcomeViewController {
                self.root.popViewController(animated: true)
                self.root.navigationBar.isHidden = true
                self.result.onNext(.cancel)
                self.result.onCompleted()
            }
        }).disposed(by: rx.disposeBag)

        let logInResult = viewModel.outputs.result.share()

        logInResult.filter({ $0.isCancel }).subscribe(onNext: { [weak self] _ in
            self?.root.popViewController(animated: true)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        logInResult.filter({ $0.isSuccess != nil })
            .map({ $0.isSuccess })
            .unwrap()
            .subscribe(onNext: { [weak self] result in
                self?.navigateToPasscode(username: result.userName, isUserBlocked: result.isBlocked)
            })
            .disposed(by: rx.disposeBag)

        return result
    }

    func navigateToPasscode(username: String, isUserBlocked: Bool) {
        coordinate(to: container.makePasscodeCoordinator(root: root, isUserBlocked: isUserBlocked)).subscribe( onNext: { result in
            self.result.onNext(.cancel)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    }
}
