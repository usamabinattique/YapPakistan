//
//  WelcomeCoordinatorReplaceable.swift
//  App
//
//  Created by Zain on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import YAPCore

public class WelcomeCoordinatorReplaceable: Coordinator<ResultType<Void>>, WelcomeCoordinatorType {
    private let container: YAPPakistanMainContainer
    private let xsrfToken: String

    public var root: UINavigationController!
    public var result = PublishSubject<ResultType<Void>>()
    // var loginResult = PublishSubject<ResultType<Void>>()
    // var welcomeResult = PublishSubject<ResultType<Void>>()
    public var b2cOnboardingResult = PublishSubject<ResultType<Void>>()

    private let window: UIWindow

    init(container: YAPPakistanMainContainer, xsrfToken: String, window: UIWindow) {
        self.container = container
        self.xsrfToken = xsrfToken
        self.window = window
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        let viewModel = WelcomeViewModel()
        let viewController = WelcomeViewController(themeService: container.themeService, viewModel: viewModel)

        root = UINavigationController(rootViewController: viewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true

        // UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: { [unowned self] in
        self.window.rootViewController = self.root
        // })

        viewModel.outputs.personal.subscribe(onNext: {[unowned self] _ in
            // AppAnalytics.shared.logEvent(OnBoardingEvent.getStarted(_params: nil))
            self.b2cOnboarding()
        }).disposed(by: rx.disposeBag)

        /*
         self.welcomeResult.map { $0.isSuccess }.unwrap()
         .subscribe(onNext: { [weak self] _ in
         guard let `self` = self else { return }
         self.b2cOnboarding()
         })
         .disposed(by: rx.disposeBag)
         */
    
        viewModel.outputs.signIn.subscribe(onNext: { [unowned self] _ in
            if let viewControllers = self.root?.viewControllers, viewControllers.count > 1, viewControllers[viewControllers.count - 2] is LoginViewController {
                self.root.popViewController(animated: true)
                self.root.navigationBar.isHidden = false
                self.result.onNext(.cancel)
                self.result.onCompleted()
            } else {
                self.login()
            }
        }).disposed(by: rx.disposeBag)
    
        Observable.merge(b2cOnboardingResult.filter { !$0.isCancel }, b2cOnboardingResult.filter { !$0.isCancel }/*, loginResult.filter { !$0.isCancel }*/)
            .subscribe(onNext: { [weak self] output in
                guard let `self` = self else { return }
                self.result.onNext(output)
                self.result.onCompleted()
            })
            .disposed(by: rx.disposeBag)
        
        return self.result
    }

    public func b2cOnboarding() {
        coordinate(to: B2COnBoardingCoordinator(container: container, xsrfToken: xsrfToken, navigationController: self.root))
            .subscribe(onNext: { [weak self] result in
                guard let `self` = self else { return }
                self.b2cOnboardingResult.onNext(result)
            })
            .disposed(by: rx.disposeBag)
    }
    
    public func login() {
        coordinate(to: LoginCoordinatorPushable(root: self.root, xsrfToken: xsrfToken, container: self.container) )
            .subscribe(onNext: { [weak self] _ in
                self?.result.onNext(.success(()))
                self?.result.onCompleted()
            })
            .disposed(by: rx.disposeBag)
    }
}
