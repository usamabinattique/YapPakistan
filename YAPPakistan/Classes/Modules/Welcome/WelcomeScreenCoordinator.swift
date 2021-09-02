//
//  WelcomeScreenCoordinator.swift
//  App
//
//  Created by Uzair on 10/06/2021.
//

import UIKit
//import YAPKit
import RxSwift
//import OnBoarding
/*
enum WelcomeResult {
    case onboarding
    case login
}

class WelcomeScreenCoordinator: Coordinator<WelcomeResult> {
    
    var root: UINavigationController!
    var result = PublishSubject<WelcomeResult>()
    var loginResult = PublishSubject<ResultType<Void>>()
    var getStartedResult = PublishSubject<ResultType<Void>>()
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<WelcomeResult> {
        
        let viewController = WelcomeScreenViewController()
        let viewModel : WelcomeScreenViewModelType = WelcomeScreenViewModel()
        viewController.viewModel =  viewModel
        root = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: { [unowned self] in
            self.window.rootViewController = self.root
        })
        
        viewModel.outputs.getStarted.subscribe(onNext: {[weak self] _ in
            self?.result.onNext(WelcomeResult.onboarding)
        }).disposed(by: rx.disposeBag)
        
        
        viewModel.outputs.signIn.subscribe(onNext: { [unowned self] _ in
            self.result.onNext(WelcomeResult.login)
        }).disposed(by: rx.disposeBag)
    
        return self.result
    }
}
*/
