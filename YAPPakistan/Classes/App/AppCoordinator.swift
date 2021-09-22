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
    let reposiotry = SplashRepository(service: XSRFService())

    private let userSession = PublishSubject<ResultType<Void>>()
    private var xsrfToken = ""

    public init(window: UIWindow,
                shortcutItem: UIApplicationShortcutItem?,
                container: YAPPakistanMainContainer) {
        self.window = window
        self.shortcutItem = shortcutItem
        self.container = container
        super.init()
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        reposiotry.fetchXSRFToken().subscribe(onNext: { _ in
            self.xsrfToken = HTTPCookieStorage.shared.cookies?.filter({ $0.name == "XSRF-TOKEN" }).first?.value ?? ""
            self.accountSelection()
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
