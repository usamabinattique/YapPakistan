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
    
    private let widgetsEditedSubject = PublishSubject<Void>()

    fileprivate lazy var biometricManager = container.parent.makeBiometricsManager()
    fileprivate lazy var notifManager = NotificationManager()
    fileprivate lazy var username: String! = container.parent.credentialsStore.getUsername()

    private var showCompleteVerification: Bool
    
    init(container: UserSessionContainer, window: UIWindow, showCompleteVerification: Bool = false) {
        self.container = container
        self.window = window
        self.showCompleteVerification = showCompleteVerification
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
        
        let menuViewModel = SideMenuViewModel(repository: container.makeAccountRepository(), accountProvider: container.accountProvider)
        let menuViewController = SideMenuViewController(themeService: container.themeService, viewModel: menuViewModel)
        viewController.menuWidth = 0.85
        viewController.menu = menuViewController
        
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
        
        menuViewModel.outputs.menuItemSelected
            .subscribe(onNext: { [weak self] menuItem in
                guard let self = self else { return }
                //viewController.view.generateSelectionImpact()
                viewController.hideMenu()
                        DispatchQueue.main.async { [self] in
                    switch menuItem {
                    case .analytics:
                        print("analytics")
                        //self.analytics(viewController, paymentCard: paymentCard)
                        self.analytics(.mock, date: Date(),theRoot: viewController)
                    case .help, .contact:
                        print("help")
                        //self.helpAndSupport(viewController)
                        
                        self.openHelpAndSupport(theRoot: viewController)
                    case .statements:
                        print("statements")
                        self.statements(viewController)
                    case .referFriend:
                        self.inviteFriend(viewController)
                    case .housholdSalary:
                        print("housholdSalary")
                        //self.householdSalary(viewController)
                        YAPToast.show("coming soon")
                    case .chat:
                        print("chat")
                        //ChatManager.shared.openChat()
                        YAPToast.show("coming soon")
                    case .notifications:
                        print("notifications")
                        YAPToast.show("coming soon")
                    case .qrCode:
                        print("qrcode")
                       // self.myQrCode(self.rootNavigationController)
                        self.navigateToAddMoneyQRCode()
                    case .dashboardWidget:
                        self.coordinateToEditWidgets()
                    case .accountLimits:
                        self.coordinateToAccountLimits(viewController)
                    case .young:
                        YAPToast.show("coming soon")
                    default:
                        break
                    }
                }}).disposed(by: disposeBag)
        
        viewController.button.rx.tap.subscribe(onNext: { [unowned self] in self.yapIt(root: viewController, height: viewController.tabBar.bounds.height)}).disposed(by: disposeBag)
        
        menuViewModel.outputs.settings.subscribe(onNext: { [weak self] _ in
            self?.settings(viewController)
        }).disposed(by: disposeBag)
        
        menuViewModel.outputs.openProfile.subscribe(onNext: {[weak self] _ in
            self?.settings(viewController)
        }).disposed(by: disposeBag)

        
        menuViewModel.outputs.shareAccountInfo
            .subscribe(onNext: { [weak self] accountInfo in
                viewController.hideMenuWithCompletion { [weak self] in
                    DispatchQueue.main.async { self?.share(accountInfo: accountInfo, root: viewController) }
                }
            }).disposed(by: disposeBag)
        
        menuViewModel.outputs.result
            .withUnretained(self)
            .subscribe(onNext: {  $0.0.resultSuccess() })
            .disposed(by: rx.disposeBag)
    }

    fileprivate func home(root: UITabBarController) {
        let homeCoordinator = HomeCoodinator(container: container, root: root, isCompleteVerification: self.showCompleteVerification)
        self.widgetsEditedSubject.bind(to: homeCoordinator.widgetsEditCompleted).disposed(by: disposeBag)
        self.coordinate(to: homeCoordinator).subscribe(onNext: { [weak self] in
            if case ResultType.success = $0 {
                // self?.result.onNext(.success(.switchAccount))
                // self?.result.onCompleted()
            }
        }).disposed(by: disposeBag)
    }
    
    func navigateToAddMoneyQRCode() {
        coordinate(to: AddMoneyQRCodeCoordinator(root: rootNavigationController, scanAllowed: true, container: container)).subscribe(onNext: { [weak self] _  in
           
        }).disposed(by: rx.disposeBag)
    }
    
    func analytics(_ paymentCard: PaymentCard, date: Date? = nil, theRoot: UIViewController) {
        coordinate(to: CardAnalyticsCoordinator(root: theRoot, container: container, card: paymentCard, date: date)).subscribe().disposed(by: rx.disposeBag)
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
        root.view.generateImpact(.light)
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
    
    func openHelpAndSupport(theRoot: UIViewController) {
        coordinate(to: HelpAndSupportCoordinator(root: theRoot, container: self.container)).subscribe(onNext: { _ in }).disposed(by: disposeBag)
    }

    fileprivate func cards(root: UITabBarController) {
        self.coordinate(to: CardsCoordinator(root: root, container: container))
            .subscribe()
            .disposed(by: disposeBag)
    }

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
    
    private func share(accountInfo: String, root: UIViewController) {
        let items = [accountInfo]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        root.present(activityVC, animated: true)
        activityVC.completionWithItemsHandler = { _, _, _, _ in
        }
    }
    
    private func settings(_ root: UIViewController) {
        coordinate(to: UserProfileCoordinator(root: root, container: self.container))
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func statements(_ viewController: UIViewController) {
        coordinate(to: CardStatementCoordinator(root: viewController, container: self.container, card: nil, repository: container.makeTransactionsRepository()))
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func coordinateToAccountLimits(_ viewController: UIViewController){
        coordinate(to: AccountLimitsCoordinator(root: viewController, container: self.container, repository: container.makeTransactionsRepository()))
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func inviteFriend(_ viewController: UIViewController) {
        let customerId = container.accountProvider.currentAccountValue.value?.customer.customerId
        let shareText = appShareMessageForMore(container.parent.referralManager.pkReferralURL(forInviter: customerId ?? ""))
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = root.view
        
        viewController.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { _, _, _, _ in
            
        }
    }
    
    private func coordinateToEditWidgets() {
        coordinate(to: EditWidgetsCoordinator(root: self.rootNavigationController, container: self.container)).subscribe(onNext: {[weak self] in
            if !($0.isCancel) {
                self?.widgetsEditedSubject.onNext(())
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
        self.container.biometricsManager.deleteBiometryForUser(phone: self.container.parent.credentialsStore.getUsername() ?? "")
        self.container.parent.credentialsStore.clearCredentials()
        let name = Notification.Name.init(.logout)
        NotificationCenter.default.post(name: name,object: nil)
        self.container.parent.configuration.eventCallback?(.logout)
        // self.result.onNext( ResultType.success(()) )
        // self.result.onCompleted()
    }
}
