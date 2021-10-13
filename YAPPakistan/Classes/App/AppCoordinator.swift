//
//  AppCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/08/2021.
//

import UIKit
import RxSwift
import YAPCore

public enum Flow {
    case onboarding(formattedPhoneNumber: String)
    case passcode(formattedPhoneNumber: String)
}

public final class AppCoordinator: Coordinator<ResultType<Void>> {

    private let window: UIWindow
    private var navigationController: UINavigationController?
    private var shortcutItem: UIApplicationShortcutItem?
    private let result = PublishSubject<ResultType<Void>>()
    private let container: YAPPakistanMainContainer
    private let flow: Flow
    let reposiotry: SplashRepository

    private let userSession = PublishSubject<ResultType<Void>>()

    public init(window: UIWindow,
                navigationController: UINavigationController,
                shortcutItem: UIApplicationShortcutItem?,
                container: YAPPakistanMainContainer,
                flow: Flow) {
        self.window = window
        self.navigationController = navigationController
        self.shortcutItem = shortcutItem
        self.container = container
        self.reposiotry = container.makeSplashRepository()
        self.flow = flow
        super.init()
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        switch flow {
        case .onboarding(let formattedPhoneNumber):
            var user = OnBoardingUser(accountType: .b2cAccount)
            user.mobileNo = PhoneNumber(formattedValue: formattedPhoneNumber)
            onboarding(user: user)
        case .passcode(let formattedPhoneNumber):
            verifyPasscode(xsrfToken: "")
        }
        return result
    }

    deinit {
        print("AppCoordinator")
    }

    func onboarding(user: OnBoardingUser) {
        self.coordinate(to:
        container.makeOnboardingCoordinator(user: user,
                                            navigationController: navigationController!)
        ).subscribe(onNext: { [weak self] result in
            switch result {
            case .success:
                ()
            case .cancel:
                self?.result.onNext(result)
                self?.result.onCompleted()
            }
        })
        .disposed(by: rx.disposeBag)
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
                switch result {
                case .cancel:
                    self.result.onNext(.cancel)
                    self.result.onCompleted()
                default:
                    self.result.onNext(.success(()))
                    self.result.onCompleted()
                }
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
