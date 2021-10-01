//
//  LiteDashboardCoordinator.swift
//  YAP
//
//  Created by Wajahat Hassan on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

class LiteDashboardCoodinator: Coordinator<ResultType<Void>> {
    private let container: UserSessionContainer
    private let window: UIWindow
    private let result = PublishSubject<ResultType<Void>>()
    private var root: UINavigationController!

    private let disposeBag = DisposeBag()

    fileprivate lazy var biometricManager = container.parent.makeBiometricsManager()
    fileprivate lazy var notifManager = NotificationManager()
    fileprivate lazy var username: String! = container.parent.credentialsStore.getUsername()

    init(container: UserSessionContainer, window: UIWindow) {
        self.container = container
        self.window = window
        super.init()
        self.initializeRoot()
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        if isNeededBiometryPermissionPrompt {
            bioMetricPermission()
        } else if !notifManager.isNotificationPermissionPrompt {
            notificationPermission()
        } else {
            presentDashBoardController()
        }

        return result
    }

    fileprivate func presentDashBoardController() {
        let viewController = container.makeLiteDashboardViewController()
        self.root.pushViewController(viewController, animated: false)
        UIView.transition(with: self.window, duration: 0.8, options: [.transitionFlipFromRight, .curveEaseInOut]) { }

        viewController.viewModel.outputs.result
            .withUnretained(self)
            .subscribe(onNext: { $0.0.resultSuccess() })
            .disposed(by: disposeBag)

        viewController.viewModel.outputs.completeVerification
            .subscribe(onNext: { [weak self] in self?.navigateToKYC() })
            .disposed(by: disposeBag)
    }

    fileprivate func bioMetricPermission() {
        let coordinator = SystemPermissionCoordinator(root: root,
                                                      type: biometricType(),
                                                      account: container.accountProvider.currentAccount,
                                                      container: container.parent)
        coordinate(to: coordinator)
            .withUnretained(self)
            .subscribe(onNext: { $0.0.notificationPermission() })
            .disposed(by: rx.disposeBag)
    }

    fileprivate func notificationPermission() {
        if !self.notifManager.isNotificationPermissionPrompt {
            let coordinator = SystemPermissionCoordinator(root: root,
                                                          type: .notification,
                                                          account: container.accountProvider.currentAccount,
                                                          container: container.parent)
            coordinate(to: coordinator)
                .withUnretained(self)
                .subscribe(onNext: { $0.0.presentDashBoardController() })
                .disposed(by: rx.disposeBag)
        }
    }

    private func navigateToKYC() {
        let kycContainer = KYCFeatureContainer(parent: container)
        coordinate(to: KYCCoordinatorPushable(container: kycContainer, root: self.root))
            .subscribe(onNext: { result in
                switch result {
                case .success:
                    self.root.popToRootViewController(animated: true)
                case .cancel:
                    break
                }
            }).disposed(by: self.disposeBag)
    }
}

// MARK: Helpers
extension LiteDashboardCoodinator {
    fileprivate func initializeRoot() {
        root = UINavigationController()
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true

        window.rootViewController = root
        window.makeKeyAndVisible()
    }

    fileprivate var isNeededBiometryPermissionPrompt: Bool {
        return !biometricManager.isBiometryPermissionPrompt(for: username) && biometricManager.isBiometrySupported
    }

    fileprivate func resultSuccess() {
        self.result.onNext( ResultType.success(()) )
        self.result.onCompleted()
    }

    fileprivate func biometricType() -> SystemPermissionType {
        let biomType = self.container.biometricsManager.deviceBiometryType == .touchID
        return biomType ? .touchID : .faceID
    }
}
