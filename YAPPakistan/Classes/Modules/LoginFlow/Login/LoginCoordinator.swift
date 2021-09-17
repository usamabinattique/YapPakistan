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
    var biometricsManager: BiometricsManager
    private let xsrfToken: String
    
    var result = PublishSubject<LoginResult>()
    
    init(root: UINavigationController,
         xsrfToken: String,
         container: YAPPakistanMainContainer,
         biometricsManager:BiometricsManager ){
        self.xsrfToken = xsrfToken
        self.root = root
        self.container = container
        self.biometricsManager = BiometricsManager()
        
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<LoginResult> {
        let loginRepository = LoginRepository(customerService: container.makeCustomersService(xsrfToken: xsrfToken), authenticationService: container.makeAuthenticationService(xsrfToken: xsrfToken), messageService: container.makeMessagesService(xsrfToken: xsrfToken))
        
        let viewModel: LoginViewModelType = LoginViewModel(repository: loginRepository, credentialsManager: CredentialsManager(), user: OnBoardingUser(accountType: .b2cAccount))
        let loginViewController = LoginViewController(themeService: container.themeService, viewModel: viewModel, isBackButton: true)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.navigationBar.isTranslucent = true
        //root.navigationBar.tintColor = .primary
        root.navigationBar.isHidden = false
        root.pushViewController(loginViewController, animated: true)
        
        viewModel.outputs.result.filter({$0.isCancel}).subscribe(onNext: { [unowned self] _ in
            self.root.popViewController(animated: true)
            self.result.onNext(.cancel)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        
        viewModel.outputs.signUp.subscribe(onNext: { [unowned self] in
            if self.root.viewControllers.count > 1, self.root.viewControllers[self.root.viewControllers.count - 2] is AccountSelectionViewController {
                self.root.popViewController(animated: true)
                self.root.navigationBar.isHidden = true
                self.result.onNext(.cancel)
                self.result.onCompleted()
            } else {
                //self.accountSelection()
            }
        }).disposed(by: rx.disposeBag)
        
        /*
        let passcodeScreen = viewModel.outputs.success.flatMap { [unowned self] params -> Observable<ResultType<Void>> in
            return self.navigateToPasscode(username: params.0, isUserBlocked: params.1)
        }
        
        Observable.merge(passcodeScreen, accountSelectionResult)
            .subscribe(onNext: { [weak self] result in
                guard let `self` = self else { return }
                self.result.onNext(result)
                self.result.onCompleted()
            }).disposed(by: rx.disposeBag)
        */
        return result
    }
}



extension LoginCoordinatorType {
    
    func biometryPermission(permissionType: SystemPermissionType, username: String = "", account: Observable<Account?>) -> Observable<ResultType<Void>> {
        
        let viewModel: SystemPermissionViewModelType = SystemPermissionViewModel(permissionType: permissionType, account: account)
        let viewController = SystemPermissionViewController(themeService: container.themeService, viewModel: viewModel, username: username)
        self.root.pushViewController(viewController, animated: true)
        
        viewModel.outputs.thanks.subscribe(onNext: { (_) in
            //Do your stuff here
        }).disposed(by: rx.disposeBag)
        
        return Observable.merge(viewModel.outputs.thanks, viewModel.outputs.success).map {_ in ResultType.success(()) }
    }
    
    func notificationPermission(account: Observable<Account?>) -> Observable<ResultType<Void>> {
        let viewModel: SystemPermissionViewModelType = SystemPermissionViewModel(permissionType: .notification, account: account)
        let viewController = SystemPermissionViewController(themeService: container.themeService, viewModel: viewModel)
        
        self.root.pushViewController(viewController, animated: true)
        viewModel.outputs.thanks.subscribe(onNext: { (_) in
            
        }).disposed(by: rx.disposeBag)
        return Observable.merge(viewModel.outputs.thanks.map { ResultType.success(()) }, viewModel.outputs.success.map { ResultType.success(())})
    }
}
