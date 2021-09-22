//
//  LoginCoordinator.swift
//  App
//
//  Created by Wajahat Hassan on 21/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore

class LoginCoordinatorPushable: Coordinator<LoginResult>, LoginCoordinatorType {

    var root: UINavigationController!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<LoginResult>()

    init(root: UINavigationController,
         xsrfToken: String,
         container: YAPPakistanMainContainer
    ){
        self.root = root
        self.container = container
        self.container.xsrfToken = xsrfToken
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<LoginResult> {

        let viewModel = container.makeLoginViewModel(loginRepository: container.makeLoginRepository())
        let loginViewController = container.makeLoginViewController(viewModel: viewModel)

        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = false
        root.pushViewController(loginViewController, animated: true)

        viewModel.outputs.signUp.subscribe(onNext: { [unowned self] in
            if self.root.viewControllers.count > 1, self.root.viewControllers[self.root.viewControllers.count - 2] is AccountSelectionViewController {
                self.root.popViewController(animated: true)
                self.root.navigationBar.isHidden = true
                self.result.onNext(.cancel)
                self.result.onCompleted()
            } else {
                //Account selection flow
            }
        }).disposed(by: rx.disposeBag)
        
        let logInResult = viewModel.outputs.result.share()
        
        logInResult.filter({ $0.isCancel }).subscribe(onNext: { [unowned self] _ in
            self.root.popViewController(animated: true)
            self.result.onNext(.cancel)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        logInResult.filter({ $0.isSuccess != nil })
            .map({$0.isSuccess})
            .unwrap()
            .subscribe(onNext: { [weak self] result in
                //self?.passcode()
                self?.navigateToPasscode(username: result.userName, isUserBlocked: result.isBlocked)
            })
            .disposed(by: rx.disposeBag)

        return result
    }
    
    func navigateToPasscode(username: String, isUserBlocked: Bool) {
        coordinate(to: container.makePasscodeCoordinator(root: root)).subscribe( onNext: { result in
            self.result.onNext(.cancel)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    }
}

/////////////

class LoginCoordinatorReplaceable: Coordinator<LoginResult>, LoginCoordinatorType {
    
    var root: UINavigationController!
    var window:UIWindow!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<LoginResult>()

    init(window: UIWindow,
         xsrfToken: String,
         container: YAPPakistanMainContainer
    ){
        self.window = window
        self.container = container
        self.container.xsrfToken = xsrfToken
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
            self.coordinate(to: AccountSelectionCoordinatorReplaceable(container: container, xsrfToken: container.xsrfToken, window: window))
        }).do(onNext:{ [weak self] _ in
            self?.result.onCompleted()
        })
        .subscribe()
        .disposed(by: rx.disposeBag)
        
        let logInResult = viewModel.outputs.result.share()
        
        logInResult.filter({ $0.isSuccess != nil })
            .map({$0.isSuccess})
            .unwrap()
            .subscribe(onNext: { [weak self] result in
                self?.navigateToPasscode(username: result.userName, isUserBlocked: result.isBlocked)
            })
            .disposed(by: rx.disposeBag)
        

        return result
    }
    
    func coordinateToWelcome() {
        coordinate(to: AccountSelectionCoordinatorReplaceable(container: container, xsrfToken: container.xsrfToken, window: window)).subscribe(onNext: { [weak self] _ in
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    }
    
    func navigateToPasscode(username: String, isUserBlocked: Bool) {
        coordinate(to: container.makePasscodeCoordinator(root: root)).subscribe( onNext: { result in
            print("Moved to passcode screen")
        }).disposed(by: rx.disposeBag)
    }
}
