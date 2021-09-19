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
        self.biometricsManager = biometricsManager
        
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<LoginResult> {
        let loginRepository = LoginRepository(customerService: container.makeCustomersService(xsrfToken: xsrfToken), authenticationService: container.makeAuthenticationService(xsrfToken: xsrfToken), messageService: container.makeMessagesService(xsrfToken: xsrfToken))
        
        let viewModel: LoginViewModelType = LoginViewModel(repository: loginRepository, credentialsManager: CredentialsManager(), user: OnBoardingUser(accountType: .b2cAccount))
        let loginViewController = LoginViewController(themeService: container.themeService, viewModel: viewModel, isBackButton: true)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.navigationBar.isTranslucent = true
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
                //Account selection flow
            }
        }).disposed(by: rx.disposeBag)
        
        return result
    }
}
