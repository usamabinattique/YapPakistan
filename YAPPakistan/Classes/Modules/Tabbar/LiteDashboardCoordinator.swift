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

        // presentDashBoardController()
        // DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.bioMetricPermission() }
        makeTabbar()
        return result
    }

    private var mainViewController: YAPTabbarController!
    private var rootNavigationController: UINavigationController!
    func makeTabbar() {
        let viewController = YAPTabbarController()
        mainViewController = viewController

//        let menuViewModel = SideMenuViewModel()
//        let menuViewController = SideMenuViewController(viewModel: menuViewModel)
//        viewController.menuWidth = 0.85
//        viewController.menu = menuViewController

        home(root: viewController)
        store(root: viewController)
        yapIt(root: viewController)

        //let yapit = UIViewController()
        //yapit.view.backgroundColor = .white
        //yapit.tabBarItem = UITabBarItem(title: "YAP it", image: nil, selectedImage: nil)
        //viewController.viewControllers?.append(yapit)

        cards(root: viewController)
        more(root: viewController)

        let navController = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
        rootNavigationController = navController
        navController.setNavigationBarHidden(true, animated: false)
        window.rootViewController = navController
        window.makeKeyAndVisible()

        //viewController.button.rx.tap.subscribe(onNext: { [unowned self] in self.yapIt(root: viewController, height: viewController.tabBar.bounds.height)}).disposed(by: disposeBag)

//        SessionManager.current.currentAccount.subscribe(onNext: { [weak self] in self?.partnerBankStatus = $0?.parnterBankStatus }).disposed(by: disposeBag)

//        NotificationCenter.default.addObserver(self, selector: #selector(backToDashbaordObsever), name: .goToDashbaord, object: nil)
//
//        menuViewModel.outputs.menuItemSelected
//            .withLatestFrom(Observable.combineLatest(CardsManager.shared.cards.map{ $0.filter{ $0.cardType == .debit }.first }.unwrap(), menuViewModel.outputs.menuItemSelected))
//            .subscribe(onNext: { [weak self] paymentCard, menuItem in
//                        guard let self = self else { return }
//                        viewController.hideMenu()
//                        DispatchQueue.main.async {
//                            switch menuItem {
//                            case .analytics:
//                                AppAnalytics.shared.logEvent(MainMenuEvent.tapAnalytics())
//                                self.analytics(viewController, paymentCard: paymentCard)
//                            case .help, .contact:
//                                AppAnalytics.shared.logEvent(MainMenuEvent.tapHelp())
//                                self.helpAndSupport(viewController)
//                            case .statements:
//                                AppAnalytics.shared.logEvent(MainMenuEvent.tapStatements())
//                                self.statements(viewController)
//                            case .referFriend:
//                                AppAnalytics.shared.logEvent(MainMenuEvent.tapReferFriend())
//                                self.inviteFriend(viewController)
//                            case .housholdSalary:
//                                self.householdSalary(viewController)
//                            case .chat:
//                                AppAnalytics.shared.logEvent(MainMenuEvent.tapLivechat())
//                                ChatManager.shared.openChat()
//                            case .notifications:
//                                AppAnalytics.shared.logEvent(MainMenuEvent.tapAlerts())
//                            case .qrCode:
//                                self.myQrCode(self.rootNavigationController)
//                            default:
//                                break
//                            }
//                        }}).disposed(by: disposeBag)
//
//        menuViewModel.outputs.settings.subscribe(onNext: { [weak self] _ in
//            self?.settings(viewController)
//        }).disposed(by: disposeBag)
//
//        menuViewModel.outputs.switchAccount.subscribe(onNext: { [weak self] in
//            self?.result.onNext(.success(.switchAccount))
//            self?.result.onCompleted()
//        }).disposed(by: disposeBag)
//
//        topupInitiationSubject.subscribe(onNext: { [unowned self] in
//            self.topup(viewController, returnsToDashboard: false, successButtonTitle: $0)
//        }).disposed(by: disposeBag)
//
//        menuViewModel.outputs.result.subscribe(onNext: {[weak self] in
//            logoutYAPUser()
//            self?.result.onNext(.success(.logout))
//            self?.result.onCompleted()
//        }).disposed(by: disposeBag)
//
//        menuViewModel.outputs.openProfile.subscribe(onNext: {[weak self] _ in
//            AppAnalytics.shared.logEvent(MainMenuEvent.tapProfile())
//            self?.settings(viewController)
//        }).disposed(by: disposeBag)
//
//        menuViewModel.outputs.shareAccountInfo.subscribe(onNext: { [weak self] accountInfo in
//            viewController.hideMenuWithCompletion { [weak self] in
//                DispatchQueue.main.async { self?.share(accountInfo: accountInfo, root: viewController) }
//            }
//        }).disposed(by: disposeBag)
    }

    fileprivate func home(root: UITabBarController) {
        self.coordinate(to: HomeCoordinator(root: root)).subscribe(onNext: { [weak self] in
            if case ResultType.success = $0 {
                // self?.result.onNext(.success(.switchAccount))
                // self?.result.onCompleted()
            }
        }).disposed(by: disposeBag)
    }

    fileprivate func store(root: UITabBarController) {
        self.coordinate(to: StoreCoordinator(root: root))
            .subscribe()
            .disposed(by: disposeBag)
    }

    fileprivate func yapIt(root: UITabBarController) {
        coordinate(to: YAPItCoordinator(root: root))
            .subscribe()
            .disposed(by: disposeBag)
    }

    fileprivate func cards(root: UITabBarController) {
        self.coordinate(to: CardsCoordinator(root: root))
            .subscribe()
            .disposed(by: disposeBag)
    }

    fileprivate func more(root: UITabBarController) {
        self.coordinate(to: MoreCoordinator(root: root))
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension LiteDashboardCoodinator {

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
        let viewController = container.makeLiteDashboardViewController()
        self.root.pushViewController(viewController, animated: false)
        UIView.transition(with: self.window, duration: 0.8, options: [.transitionFlipFromRight, .curveEaseInOut]) { }

        viewController.viewModel.outputs.result
            .withUnretained(self)
            .subscribe(onNext: { $0.0.resultSuccess() })
            .disposed(by: disposeBag)

        viewController.viewModel.outputs.completeVerification
            .subscribe(onNext: { [weak self] isTrue in
                self?.navigateToKYC(isTrue)
            })
            .disposed(by: disposeBag)
    }

    #warning("FIXME")
    private func navigateToKYC( _ isTrue: Bool) {
        let kycContainer = KYCFeatureContainer(parent: container)

        if isTrue {

        coordinate(to: KYCCoordinator(container: kycContainer, root: self.root))
            .subscribe(onNext: { result in
                switch result {
                case .success:
                    self.root.popToRootViewController(animated: true)
                case .cancel:
                    break
                }
            }).disposed(by: self.disposeBag)
        } else {
            let viewController = kycContainer.makeManualVerificationViewController()

            viewController.viewModel.outputs.back.withUnretained(self)
                .subscribe(onNext: { `self`, _ in
                    self.root.setViewControllers([self.root.viewControllers[0]], animated: true)
                })
                .disposed(by: rx.disposeBag)

            root.pushViewController(viewController, animated: true)
            root.setNavigationBarHidden(true, animated: true)
        }
    }
}

// MARK: Helpers
extension LiteDashboardCoodinator {
    fileprivate func initializeRoot() {
        root = UINavigationController()
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.isTranslucent = true
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.setNavigationBarHidden(true, animated: true)

        window.rootViewController = root
        window.makeKeyAndVisible()
    }

    fileprivate var isNeededBiometryPermissionPrompt: Bool {
        return !biometricManager.isBiometryPermissionPrompt(for: username) && biometricManager.isBiometrySupported
    }

    fileprivate func resultSuccess() {
        NotificationCenter.default.post(name: NSNotification.Name("LOGOUT"), object: nil)
        // self.result.onNext( ResultType.success(()) )
        // self.result.onCompleted()
    }
}
