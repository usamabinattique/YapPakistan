//
//  AppCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/08/2021.
//

import UIKit
import RxSwift
import YAPCore

public class AppCoordinator: Coordinator<ResultType<Void>> {

    private let window: UIWindow
    private var navigationController: UINavigationController?
    private var shortcutItem: UIApplicationShortcutItem?
    private let result = PublishSubject<ResultType<Void>>()
    private let container: YAPPakistanMainContainer
    let reposiotry: SplashRepository

    private let userSession = PublishSubject<ResultType<Void>>()
    private var xsrfToken = ""
    let credentialStore = CredentialsManager()

    public init(window: UIWindow,
                shortcutItem: UIApplicationShortcutItem?,
                container: YAPPakistanMainContainer) {
        self.window = window
        self.shortcutItem = shortcutItem
        self.container = container
        self.reposiotry = container.makeSplashRepository()
        super.init()
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        reposiotry.fetchXSRFToken().subscribe(onNext: { [unowned self] _ in
            self.xsrfToken = HTTPCookieStorage.shared.cookies?.filter({ $0.name == "XSRF-TOKEN" }).first?.value ?? ""
            
        if !UserDefaults.standard.bool(forKey: "isSecondLogin") {
            self.accountSelection()
            _ = credentialStore.setRemembersId(false)
            _ = credentialStore.clearUsername()
        } else if self.credentialStore.credentialsAvailable() {
            self.verifyPasscode()
        } else {
            self.loginScreen()
        }
            
        UserDefaults.standard.setValue(true, forKey: "isSecondLogin")
            
        }).disposed(by: rx.disposeBag)

        // self.showDummyController()
        // self.accountSelection()
        // self.onboarding()

        return result
    }

    func onboarding() {
        let viewModel = OnBoardingViewModel()
        let viewController = OnBoardingViewController(themeService: container.themeService, viewModel: viewModel, withChildNavigation: UINavigationController())
        window.rootViewController = viewController
    }

    func accountSelection() { // -> Observable<ResultType<Void>> {
        coordinate(to: AccountSelectionCoordinatorReplaceable(container: container, xsrfToken: xsrfToken, window: window)).subscribe { result in
            self.result.onNext(.success(()))
            self.result.onCompleted()
        }.disposed(by: rx.disposeBag)
    }
    
    func verifyPasscode() {
        coordinate(to: PasscodeCoordinatorReplaceable(window: window, xsrfToken: xsrfToken, container: container)).subscribe(onNext: { result in
            self.result.onNext(.success(()))
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    }
    
    func loginScreen() {
        coordinate(to: LoginCoordinatorReplaceable(window: window, xsrfToken: xsrfToken, container: container)).subscribe(onNext: { result in
            self.result.onNext(.success(()))
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    }
    
}

// MARK: NAVIGATIONS
extension AppCoordinator {
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
}

// MARK: HELPERS
fileprivate extension AppCoordinator {
//    func splashDidComplete(shortcutItem: UIApplicationShortcutItem?)  -> Observable<ResultType<NavigationType>> {
//         return self.coordinate(
//            to: SplashCoordinator (
//                window: window,
//                shortcutItem: shortcutItem,
//                store: CredentialsManager(),
//                repository: SplashRepository(service: XSRFService() )
//            )
//        )
//    }
}
