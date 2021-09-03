//
//  AccountSelectionCoordinator.swift
//  App
//
//  Created by Zain on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
/*
import UIKit
import YAPKit
import RxSwift
import YAP
import OnBoarding
import AppAnalytics

class AccountSelectionCoordinatorReplaceable: Coordinator<ResultType<Void>>, AccountSelectionCoordinatorType {
    var root: UINavigationController!
    var result = PublishSubject<ResultType<Void>>()
    var loginResult = PublishSubject<ResultType<Void>>()
    var welcomeResult = PublishSubject<ResultType<Void>>()
    var b2cOnboardingResult = PublishSubject<ResultType<Void>>()
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<ResultType<Void>> {
        let viewController = AccountSelectionViewController()
        let viewModel: AccountSelectionViewModelType = AccountSelectionViewModel()
        viewController.viewModel = viewModel
        
        root = UINavigationController(rootViewController: viewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: { [unowned self] in
            self.window.rootViewController = self.root
        })
        
        viewModel.outputs.personal.subscribe(onNext: {[unowned self] _ in
            AppAnalytics.shared.logEvent(OnBoardingEvent.getStarted(_params: nil))
            self.b2cOnboarding()
        }).disposed(by: disposeBag)
        //        let business = viewModel.outputs.business.flatMap{ [unowned self] _ -> Observable<ResultType<Void>> in
        //            self.navigateToWelcom(welcomType: .b2b)
        //        }
        //
        
        self.welcomeResult.map { $0.isSuccess }.unwrap()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.b2cOnboarding()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.signIn.subscribe(onNext: { [unowned self] _ in
            
            if let viewControllers = self.root?.viewControllers, viewControllers.count > 1, viewControllers[viewControllers.count - 2] is LoginViewController {
                self.root.popViewController(animated: true)
                self.root.navigationBar.isHidden = false
                self.result.onNext(.cancel)
                self.result.onCompleted()
            } else {
                self.login()
            }
        }).disposed(by: disposeBag)
        
        Observable.merge(b2cOnboardingResult.filter { !$0.isCancel }, b2cOnboardingResult.filter { !$0.isCancel }, loginResult.filter { !$0.isCancel })
            .subscribe(onNext: { [weak self] output in
                guard let `self` = self else { return }
                self.result.onNext(output)
                self.result.onCompleted()
            })
            .disposed(by: disposeBag)
        
        return self.result
    }
    
}

class AccountSelectionCoordinatorPushable: Coordinator<ResultType<Void>>, AccountSelectionCoordinatorType {
    var root: UINavigationController!
    var result = PublishSubject<ResultType<Void>>()
    var loginResult = PublishSubject<ResultType<Void>>()
    var welcomeResult = PublishSubject<ResultType<Void>>()
    var b2cOnboardingResult = PublishSubject<ResultType<Void>>()
    var b2bOnboardingResult = PublishSubject<ResultType<Void>>()
    
    init(root: UINavigationController) {
        self.root = root
    }
    
    override func start() -> Observable<ResultType<Void>> {
        let viewController = AccountSelectionViewController()
        let viewModel: AccountSelectionViewModelType = AccountSelectionViewModel()
        viewController.viewModel = viewModel
        
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true
        root.pushViewController(viewController, animated: true)
        
        viewModel.outputs.personal.subscribe(onNext: {[unowned self] _ in
            AppAnalytics.shared.logEvent(OnBoardingEvent.getStarted(_params: nil))
            self.b2cOnboarding()
        }).disposed(by: disposeBag)
        
        self.welcomeResult.map { $0.isSuccess }.unwrap()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.b2cOnboarding()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.signIn.subscribe(onNext: { [unowned self] _ in
            
            if let viewControllers = self.root?.viewControllers, viewControllers.count > 1, viewControllers[viewControllers.count - 2] is LoginViewController {
                self.root.popViewController(animated: true)
                self.root.navigationBar.isHidden = false
                self.result.onNext(.cancel)
                self.result.onCompleted()
            } else {
                self.login()
            }
        }).disposed(by: disposeBag)
        
        Observable.merge(b2cOnboardingResult.filter { !$0.isCancel }, b2cOnboardingResult.filter { !$0.isCancel }, loginResult.filter { !$0.isCancel })
            .subscribe(onNext: { [weak self] output in
                guard let `self` = self else { return }
                self.result.onNext(output)
                self.result.onCompleted()
            })
            .disposed(by: disposeBag)
        
        return self.result
    }
    
}
*/
