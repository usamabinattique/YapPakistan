//
//  ToolbarCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

class TabbarCoodinator: Coordinator<ResultType<Void>> {
    private let container: UserSessionContainer
    private let window: UIWindow
    private let result = PublishSubject<ResultType<Void>>()
    private var root: UINavigationController!
    private var contactsManager: ContactsManager!
//    private let moreCoordination = PublishSubject<MoreExternalCoordinationType>()

    private let disposeBag = DisposeBag()

    fileprivate lazy var biometricManager = container.parent.makeBiometricsManager()
    fileprivate lazy var notifManager = NotificationManager()
    fileprivate lazy var username: String! = container.parent.credentialsStore.getUsername()

    init(container: UserSessionContainer, window: UIWindow) {
        self.container = container
        self.window = window
        super.init()
        self.initializeRoot()
        self.contactsManager = ContactsManager(repository: container.makeY2YRepository())
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        makeTabbar()
        return result
    }

    private var mainViewController: YAPTabbarController!
    private var rootNavigationController: UINavigationController!
    func makeTabbar() {
        let viewController = YAPTabbarController(themeService: container.themeService)
        mainViewController = viewController

        //        let menuViewModel = SideMenuViewModel()
        //        let menuViewController = SideMenuViewController(viewModel: menuViewModel)
        //        viewController.menuWidth = 0.85
        //        viewController.menu = menuViewController

        home(root: viewController)
        store(root: viewController)
        yapIt(root: viewController)
        cards(root: viewController)
        more(root: viewController)

        let navController = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
        rootNavigationController = navController
        navController.setNavigationBarHidden(true, animated: false)
        window.rootViewController = navController
        window.makeKeyAndVisible()

        viewController.button.rx.tap.subscribe(onNext: { [unowned self] in self.yapIt(root: viewController, height: viewController.tabBar.bounds.height)}).disposed(by: disposeBag)

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
        self.coordinate(to: HomeCoodinator(container: container, root: root)).subscribe(onNext: { [weak self] in
            if case ResultType.success = $0 {
                // self?.result.onNext(.success(.switchAccount))
                // self?.result.onCompleted()
            }
        }).disposed(by: disposeBag)
    }

    fileprivate func store(root: UITabBarController) {
        self.coordinate(to: StoreCoordinator(root: root, container: container))
            .subscribe()
            .disposed(by: disposeBag)
    }

    fileprivate func yapIt(root: UITabBarController) {
        let yapit = UIViewController()
        yapit.view.backgroundColor = .white
        yapit.tabBarItem = UITabBarItem(title: "YAP it", image: nil, selectedImage: nil)
        root.viewControllers?.append(yapit)
    }
    fileprivate func yapIt(root: UITabBarController, height: CGFloat) {
        coordinate(to: YAPItCoordinator(root: root, container: container, tabBarHeight: height))
            .withUnretained(self)
            .subscribe(onNext: { `self`, value in
                if case let ResultType.success(result) = value {
                    switch result {
                    case .sendMoney: self.sendMoney(root)
                    case .addMoney:     self.topup(root)
                    case .payBills: break   // self.y2y(root)
                }
            }
        }).disposed(by: disposeBag)
    }

    fileprivate func cards(root: UITabBarController) {
        self.coordinate(to: CardsCoordinator(root: root, container: container))
            .subscribe()
            .disposed(by: disposeBag)
    }
    
//    fileprivate func more(root: UITabBarController, notificationManager: InAppNotificationManager) {
//        self.coordinate(to: MoreCoordinator(root: root, tourGuideRepository: tourGuideRepository, repository: moreRepository, externalCoordination: moreCoordination.asObserver(), notificationManager: notificationManager)).subscribe(onNext: { [weak self] result in
//            guard let `self` = self else { return }
//            if case ResultType.success(UserProfileResult.logout) = result {
//                self.result.onNext(.success(.logout))
//                self.result.onCompleted()
//            }
//        }).disposed(by: disposeBag)
//
//        moreCoordination.subscribe(onNext: { [weak self] in
//            self?.moreExternalCoordination($0)
//        }).disposed(by: disposeBag)
//    }

    fileprivate func more(root: UITabBarController) {
        self.coordinate(to: MoreCoordinator(root: root, container: container))
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    fileprivate func sendMoney(_ root: UIViewController) {
        coordinate(to: SendMoneyDashboardCoordinator(root: root, container: self.container, contactsManager: self.contactsManager, repository: container.makeY2YRepository())).subscribe(onNext: { result in
            if case ResultType.success = result {
                root.dismiss(animated: true, completion: nil)
                (root as? UITabBarController)?.selectedIndex = 0
            }
        }).disposed(by: disposeBag)
                   }
    private func topup(_ root: UIViewController, returnsToDashboard: Bool = true, successButtonTitle: String? = nil) {
        let rootNav = returnsToDashboard ? root : root.lastPresentedViewController ?? root
        coordinate(to: AddMoneyCoordinator(root: rootNav, container: self.container, contactsManager: self.contactsManager, repository: container.makeY2YRepository())).subscribe(onNext: { result in
            if case ResultType.success = result, returnsToDashboard {
                (root as? UITabBarController)?.selectedIndex = 0
            }
        }).disposed(by: disposeBag)
    }

}

// MARK: Helpers
extension TabbarCoodinator {
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
      //  NotificationCenter.default.post(name: NSNotification.Name("LOGOUT"), object: nil)
        let name = Notification.Name.init(.logout)
        NotificationCenter.default.post(name: name,object: nil)
        // self.result.onNext( ResultType.success(()) )
        // self.result.onCompleted()
    }
}
