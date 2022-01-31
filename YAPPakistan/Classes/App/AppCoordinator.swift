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
           // _ = container.credentialsStore.secure(username: formattedPhoneNumber)
            verifyPasscode()
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

    func verifyPasscode() {
        coordinate(to: container.makePasscodeCoordinatorReplaceable(window: window))
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
}
