//
//  AppCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/08/2021.
//

import UIKit
import RxSwift

public class AppCoordinator:Coordinator<ResultType<Void>> {
    
    private let window: UIWindow
    private var navigationController: UINavigationController?
    private var shortcutItem: UIApplicationShortcutItem?
    
    private let currentSession = PublishSubject<ResultType<Void>>()
    
    public init(window:UIWindow, shortcutItem:UIApplicationShortcutItem?) {
        self.window = window
        self.shortcutItem = shortcutItem
        super.init()
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        print("HEllo")
        self.splash(shortcutItem: nil)
        return currentSession
    }
    
    func splash(shortcutItem: UIApplicationShortcutItem?) {
        self.coordinate(
            to: SplashCoordinator (
                window: window,
                shortcutItem: shortcutItem,
                store: CredentialsManager(),
                repository: SplashRepository(service: XSRFService() )
            )
        )
        .subscribe(onNext: { [weak self] result in
            self?.handleSplashResponse(result: result)
        })
        .disposed(by: rx.disposeBag)
    }
    
    private func handleSplashResponse(result:ResultType<NavigationType>) {
        guard let result = result.isSuccess else { return }
        switch result {
            case .login(let xsrfToken):
                print("login result: sxrfToken, \(xsrfToken)")
                showWelcomeScreen(authorization: GuestServiceAuthorization(xsrf: xsrfToken))
            case .passcode(let xsrfToken):
                print("passcode result: sxrfToken, \(xsrfToken)")
            case .onboarding(let xsrfToken):
                showWelcomeScreen(authorization: GuestServiceAuthorization(xsrf: xsrfToken))
        }
    }
}

func showWelcomeScreen(authorization: GuestServiceAuthorization) {
    /* self.coordinate(to: WelcomeScreenCoordinator(window: self.window))
        .subscribe(onNext: { [unowned self] result in
            switch result {
            case .onboarding:
                startB2BRegistration(authorization: authorization)
            case .login:
                showLoginScreen(authorization: authorization)
            }
        })
        .disposed(by: rx.disposeBag) */
}
