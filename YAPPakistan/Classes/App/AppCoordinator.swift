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
        reposiotry.fetchXSRFToken()
            .subscribe(onNext: { [unowned self] _ in

                let xsrfToken = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == "XSRF-TOKEN" })?.value ?? ""

                if AppSettings.isAppRunFirstTime {
                    prepareFirstTimeLaunch(xsrfToken: xsrfToken)
                } else if container.credentialsStore.remembersId == true &&
                            container.credentialsStore.credentialsAvailable() {
                    verifyPasscode(xsrfToken: xsrfToken)
                } else {
                    loginScreen(xsrfToken: xsrfToken)
                }

            }).disposed(by: rx.disposeBag)

        return result
    }

    func welcome(xsrfToken: String) {
        coordinate(to: container.makeWelcomeCoordinator(xsrfToken: xsrfToken, window: window)).subscribe { result in
            self.result.onNext(.success(()))
            self.result.onCompleted()
        }.disposed(by: rx.disposeBag)
    }

    func verifyPasscode(xsrfToken: String) {
        coordinate(to: container.makePasscodeCoordinatorReplaceable(xsrfToken: xsrfToken, window: window))
            .subscribe(onNext: { result in
                self.result.onNext(.success(()))
                self.result.onCompleted()
            }).disposed(by: rx.disposeBag)
    }

    func loginScreen(xsrfToken: String) {
        coordinate(to: container.makeLoginCoordinatorReplaceable(xsrfToken: xsrfToken, window: window))
            .subscribe(onNext: { result in
                self.result.onNext(.success(()))
                self.result.onCompleted()
            }).disposed(by: rx.disposeBag)
    }
}

// MARK: Helpers
fileprivate extension AppCoordinator {
    func prepareFirstTimeLaunch(xsrfToken: String) {
        self.welcome(xsrfToken: xsrfToken)
        _ = container.credentialsStore.setRemembersId(false)
        _ = container.credentialsStore.clearUsername()
        AppSettings.isAppRunFirstTime = false
    }
}
