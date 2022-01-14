//
//  HomeCoordinator.swift
//  YAP
//
//  Created by Wajahat Hassan on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

class HomeCoodinator: Coordinator<ResultType<Void>> {
    private let result = PublishSubject<ResultType<Void>>()
    private let container: UserSessionContainer
    private var root: UITabBarController!
    private var navigationRoot: UINavigationController!

    fileprivate lazy var biometricManager = container.parent.makeBiometricsManager()
    fileprivate lazy var notifManager = NotificationManager()
    fileprivate lazy var username: String! = container.parent.credentialsStore.getUsername()

    init(container: UserSessionContainer,
         root: UITabBarController) {
        self.container = container
        self.root = root
        super.init()
        self.initializeRootNavigation()
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        presentDashBoardController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.bioMetricPermission() }
        return result
    }
    
    fileprivate func bioMetricPermission() {
        guard isNeededBiometryPermissionPrompt else {
            notificationPermission()
            return
        }

        let viewController = container.parent.makeBiometricPermissionViewController()
        viewController.modalPresentationStyle = .fullScreen

        self.root.present(viewController, animated: true, completion: nil)

        viewController.viewModel.outputs.thanks.merge(with: viewController.viewModel.outputs.success)
            .subscribe(onNext: { [weak self] _ in
                self?.root.dismiss(animated: true) { [weak self] in self?.notificationPermission() }
            })
            .disposed(by: rx.disposeBag)
    }

    fileprivate func notificationPermission() {
        guard !self.notifManager.isNotificationPermissionPrompt else { return }

        let viewController = container.parent.makeNotificationPermissionViewController()
        viewController.modalPresentationStyle = .fullScreen

        self.root.present(viewController, animated: true, completion: nil)

        viewController.viewModel.outputs.thanks.merge(with: viewController.viewModel.outputs.success)
            .subscribe(onNext: { [weak self] _ in self?.root.dismiss(animated: true, completion: nil) })
            .disposed(by: rx.disposeBag)
    }

    fileprivate func presentDashBoardController() {
        let viewController = container.makeHomeViewController()


        // self.root.pushViewController(viewController, animated: false)
        // UIView.transition(with: self.window, duration: 0.8, options: [.transitionFlipFromRight, .curveEaseInOut]) { }

        navigationRoot.pushViewController(viewController, animated: false)
        navigationRoot.navigationBar.isHidden = true
        navigationRoot.tabBarItem = UITabBarItem(title: "Home",
                                                 image: UIImage(named: "icon_tabbar_home", in: .yapPakistan),
                                                 selectedImage: nil)

        if root.viewControllers == nil {
            root.viewControllers = [navigationRoot]
        } else {
            root.viewControllers?.append(navigationRoot)
        }

        viewController.viewModel.outputs.result
            .withUnretained(self)
           .subscribe(onNext: {  $0.0.resultSuccess() })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.completeVerification
            .subscribe(onNext: { [weak self] isTrue in
                self?.navigateToKYC(isTrue)
            })
            .disposed(by: rx.disposeBag)
    }

    #warning("FIXME")
    private func navigateToKYC( _ isTrue: Bool) {
        let kycContainer = KYCFeatureContainer(parent: container)

        if isTrue {

// <<<<<<< Updated upstream:YAPPakistan/Classes/Modules/Tabbar/Items/Home/HomeCoordinator.swift
        coordinate(to: KYCCoordinator(container: kycContainer, root: self.navigationRoot))
// =======
//        coordinate(to: KYCCoordinator(container: kycContainer, root: self.root))
// >>>>>>> Stashed changes:YAPPakistan/Classes/Modules/LiteDashboard/LiteDashboardCoordinator.swift
            .subscribe(onNext: { result in
                switch result {
                case .success:
                    self.navigationRoot.popToRootViewController(animated: true)
                case .cancel:
                    break
                }
            }).disposed(by: rx.disposeBag)
        } else {
            let viewController = kycContainer.makeManualVerificationViewController()

            viewController.viewModel.outputs.back.withUnretained(self)
                .subscribe(onNext: { `self`, _ in
// <<<<<<< Updated upstream:YAPPakistan/Classes/Modules/Tabbar/Items/Home/HomeCoordinator.swift
                    self.root.setViewControllers([self.navigationRoot.viewControllers[0]], animated: true)
                })
                .disposed(by: rx.disposeBag)

            self.navigationRoot.pushViewController(viewController, animated: true)
            self.navigationRoot.setNavigationBarHidden(true, animated: true)
//=======
//                    self.root.setViewControllers([self.root.viewControllers[0]], animated: true)
//                })
//                .disposed(by: rx.disposeBag)
//
//            root.pushViewController(viewController, animated: true)
//            root.setNavigationBarHidden(true, animated: true)
//>>>>>>> Stashed changes:YAPPakistan/Classes/Modules/LiteDashboard/LiteDashboardCoordinator.swift
        }
    }
}

// MARK: Helpers
extension HomeCoodinator {
    fileprivate func initializeRootNavigation() {
        navigationRoot = UINavigationController()
        navigationRoot.interactivePopGestureRecognizer?.isEnabled = false
        navigationRoot.navigationBar.isTranslucent = true
        navigationRoot.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationRoot.navigationBar.shadowImage = UIImage()
        navigationRoot.setNavigationBarHidden(true, animated: true)
    }

    fileprivate var isNeededBiometryPermissionPrompt: Bool {
        return !biometricManager.isBiometryPermissionPrompt(for: username) && biometricManager.isBiometrySupported
    }

    fileprivate func resultSuccess() {
       // NotificationCenter.default.post(name: NSNotification.Name("LOGOUT"), object: nil)
        let name = Notification.Name.init(.logout)
        NotificationCenter.default.post(name: name,object: nil)
    }
}
