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
    fileprivate lazy var username: String! = container.parent.credentialsStore.getUsername() ?? ""
    fileprivate let transactionCategoryResult = PublishSubject<Void>()
    let widgetsEditCompleted = PublishSubject<Void>()
    private var contactsManager: ContactsManager!
    private var isCompleteVerification: Bool!
    
    init(container: UserSessionContainer,
         root: UITabBarController, isCompleteVerification: Bool) {
        self.isCompleteVerification = isCompleteVerification
        self.container = container
        self.root = root
        super.init()
        self.initializeRootNavigation()
        self.contactsManager = ContactsManager(repository: container.makeY2YRepository())
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
        
        viewController.viewModel.outputs.showCreditLimit.subscribe(onNext: { [weak self] _ in
            self?.showCreditLimit()
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.setPin.withUnretained(self).subscribe(onNext: { `self`, card  in
            self.setPinIntroScreen(cardSerial: card.cardSerialNumber ?? "")
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.search.withLatestFrom(viewController.viewModel.outputs.debitCard).subscribe(onNext: { [weak self] card in
            self?.navigateToSearch(card: card)
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.profileTap.subscribe(onNext: { [weak self] _ in
            self?.navigateToProfile()
        }).disposed(by: rx.disposeBag)
        
        // show analytics
        viewController.viewModel.outputs.showAnalytics
            .withLatestFrom(viewController.viewModel.outputs.debitCard).compactMap{$0}
            .subscribe(onNext: { [weak self] in self?.analytics($0) })
            .disposed(by: rx.disposeBag)
        
        transactionCategoryResult.bind(to: viewController.viewModel.inputs.categoryChangedObserver).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.menuTap.subscribe(onNext: { [weak self] in
            (self?.root as? MenuViewController)?.showMenu()
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.selectedWidget.subscribe(onNext: { [weak self] in
            guard let widget = $0 else { return }
            self?.navigateFromWidgets(selectedWidget: widget)
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.openFilter.subscribe(onNext: { [weak self] in
            //AppAnalytics.shared.logEvent(DashboardEvent.tapFilterTransactions())
            self?.navigateToFilterSelection(selectedFilter: $0, resultObserver: viewController.viewModel.inputs.filterSelectedObserver)
        }).disposed(by: rx.disposeBag)
        
        
        viewController.viewModel.outputs.topUp.withUnretained(self).subscribe(onNext: { `self`, card in
            self.topup(self.root)
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.transactionDetails
            .subscribe(onNext: { obj in
                print(obj)
                self.navigateToTransactionDetails(transaction: obj)
            })
            .disposed(by: rx.disposeBag)
        
        //!!!: show complete verification flow directly, if coming from onBoarding first time
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) { [unowned self] in
            if self.isCompleteVerification {
                viewController.viewModel.inputs.completeVerificationObserver.onNext(())
            }
        }
    }
    
    func showCreditLimit() {
        let viewModel = CreditLimitPopSelectionViewModel()
        let viewController = CreditLimitPopSelectionViewController(viewModel, themeService: container.themeService)
        viewController.show(in: navigationRoot)
        
//        viewModel.outputs.popSelected
//            .subscribe(onNext: { selectedReasonObserver.onNext($0) })
//            .disposed(by: rx.disposeBag)
    }

    #warning("FIXME")
    private func navigateToKYC( _ isTrue: Bool) {
        let kycContainer = KYCFeatureContainer(parent: container)

        if isTrue {
            self.navigationRoot.setNavigationBarHidden(true, animated: true)
        coordinate(to: KYCCoordinator(container: kycContainer, root: self.navigationRoot))
            .subscribe(onNext: { [unowned self] result in
                self.navigationRoot.setNavigationBarHidden(false, animated: true)
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
                    self.navigationRoot.setNavigationBarHidden(false, animated: true)
                   // self.root.setViewControllers([self.navigationRoot.viewControllers[0]], animated: true)
                    self.navigationRoot.popToRootViewController(animated: true)
                })
                .disposed(by: rx.disposeBag)

            self.navigationRoot.pushViewController(viewController, animated: true)
            self.navigationRoot.setNavigationBarHidden(true, animated: true)
        }
    }
}

// MARK: Helpers
extension HomeCoodinator {
    fileprivate func initializeRootNavigation() {
        navigationRoot =  UINavigationControllerFactory.createAppThemedNavigationController(themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular) //UINavigationController()
//        navigationRoot.interactivePopGestureRecognizer?.isEnabled = false
//        navigationRoot.navigationBar.isTranslucent = true
//        navigationRoot.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationRoot.navigationBar.shadowImage = UIImage()
//        navigationRoot.setNavigationBarHidden(true, animated: true)
    }

    fileprivate var isNeededBiometryPermissionPrompt: Bool {
        return !biometricManager.isBiometryPermissionPrompt(for: username) && biometricManager.isBiometrySupported
    }

    fileprivate func resultSuccess() {
       // NotificationCenter.default.post(name: NSNotification.Name("LOGOUT"), object: nil)
        self.container.biometricsManager.deleteBiometryForUser(phone: self.container.parent.credentialsStore.getUsername() ?? "")
        self.container.parent.credentialsStore.clearCredentials()
        let name = Notification.Name.init(.logout)
        NotificationCenter.default.post(name: name,object: nil)
        self.container.parent.configuration.eventCallback?(.logout)
    }
}

//MARK: Search
extension HomeCoodinator {
    func navigateToSearch(card: PaymentCard?, viewModel: TransactionsViewModel? = nil) {
        let coordinator = SearchTransactionsCoordinator(card: card, root: root,container: container)
        //coordinator.viewModel = viewModel
        
        coordinate(to: coordinator).subscribe(onNext: {[weak self] result in
            if !(result.isCancel) {
                self?.transactionCategoryResult.onNext(())
            }
        }).disposed(by: rx.disposeBag) 
    }
}

//MARK: Set Pin
extension HomeCoodinator {
    func setPinIntroScreen(cardSerial: String) {
        let viewController = SetpinIntroModuleBuilder(container: self.container).viewController()
        self.navigationRoot.pushViewController(viewController)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.setPin(cardSerial: cardSerial) })
            .disposed(by: rx.disposeBag)
        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigationRoot.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)
    }

    func setPin(cardSerial: String) {
        let viewController = SetCardPinModuleBuilder(cardSerialNumber: cardSerial,
                                                     container: self.container).viewController()
        self.navigationRoot.pushViewController(viewController)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { $0.0.confirmPin(code: $0.1.pinCode, cardSerial: $0.1.cardSerial) })
            .disposed(by: rx.disposeBag)
        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigationRoot.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)
    }
    
    func confirmPin(code: String, cardSerial: String) {
        let viewController = ConfirmCardPinModuleBuilder(pinCode: code,
                                                         cardSerialNumber: cardSerial,
                                                         container: self.container).viewController()
        self.navigationRoot.pushViewController(viewController)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.setPinSuccess() })
            .disposed(by: rx.disposeBag)
        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigationRoot.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)
    }

    func setPinSuccess() {
        let viewController = SetPintSuccessModuleBuilder(container: self.container).viewController()
        self.navigationRoot.pushViewController(viewController)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.navigationRoot.popToRootViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
}

extension HomeCoodinator {
    
    func navigateFromWidgets(selectedWidget: WidgetCode) {
        switch selectedWidget {
        case .addMoney:
           // self.coordinate(to: AddMoneyCoordinator(root: root)).subscribe().disposed(by: rx.disposeBag)
            print("add money")
            topup(root)
        case .sendMoney:
            print("add money")
            //navigateToSendMoney(root: root)
            sendMoney(root)
        case .qrCode:
            navigateToAddMoneyQRCode()
        case .bills:
            //payBills(root)
            YAPToast.show("coming soon")
        case .offers:
            YAPToast.show("coming soon")
        case .coins:
            YAPToast.show("coming soon")
        case .young:
            YAPToast.show("coming soon")
        case .houseHold:
            YAPToast.show("coming soon")
        case .statements:
           // YAPToast.show("coming soon")
            statements(root)
        case .edit:
            self.openWidgets()
        case .bankTransfer:
            YAPToast.show("Coming soon")
        case .unknown:
            YAPToast.show("coming soon")
            break
        }
    }

    func openWelcome() {
//        DispatchQueue.main.async {
//            self.coordinate(to: YAPForYouCoordinator(root: self.navigationRoot, repository: self.moreRepository)).subscribe().disposed(by: self.disposeBag)
//        }
    }
    
    private func statements(_ viewController: UIViewController) {
        navigate(to: CardStatementCoordinator(root: viewController, container: self.container, card: nil, repository: container.makeTransactionsRepository()))
            .subscribe()
            .disposed(by: rx.disposeBag)
    }
    
    func openWidgets()  {
        
        coordinate(to: EditWidgetsCoordinator(root: self.navigationRoot, container: container)).subscribe(onNext: {[weak self] in
            if !($0.isCancel) {
                self?.widgetsEditCompleted.onNext(())
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func openPopup() {
      /*  let viewModel = HideWidgetPopupViewModel()
        let viewController = HideWidgetPopupViewController(viewModel: viewModel)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = YAPActionSheetRootViewController()
        alertWindow.backgroundColor = .clear
        alertWindow.windowLevel = .alert + 1
        alertWindow.makeKeyAndVisible()
        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .overCurrentContext
        alertWindow.rootViewController?.present(nav, animated: false, completion: nil)
        viewController.window = alertWindow
        
        viewModel.cancel.subscribe(onNext: {
            nav.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.hideWidget.subscribe(onNext: {
            nav.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.hideWidget.bind(to: hideWidgetsResult).disposed(by: disposeBag)
        
        viewModel.cancel.bind(to: widgetSelectionSwitchResult).disposed(by: disposeBag) */
    }
    
    func openChat() {
//        ChatManager.shared.openChat()
    }

  

    func navigateToChnageUnvarifiedEmailAddress() {
//        coordinate(to: ChangeUnverifiedEmailAddressCoordinator(root: navigationRoot)).subscribe(onNext: { [weak self] result in
//            if case ResultType.success = result {
//                self?.root.dismiss(animated: true, completion: nil)
//            }
//        }).disposed(by: disposeBag)
    }

    func navigateToTransactionDetails(transaction: TransactionResponse) {
        self.navigate(to: TransactionDetailsCoordinator(root: root, container: container, repository: container.makeTransactionsRepository(), transaction: transaction))
            .subscribe(onNext: {[weak self] result in
                if !(result.isCancel) {
                    self?.transactionCategoryResult.onNext(())
                }
            }).disposed(by: rx.disposeBag)
    }

    func navigateToFilterSelection(selectedFilter: TransactionFilter?, resultObserver: AnyObserver<TransactionFilter?>) {
        let viewModel = TransactionFilterViewModel(selectedFilter, repository: container.makeTransactionsRepository(),isHomeTransactions: true)
        let viewController = TransactionFilterViewController(viewModel: viewModel, themeService: container.themeService)
        let nav = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)

        root.present(nav, animated: true, completion: nil)

        viewModel.outputs.result.subscribe(onNext: { resultObserver.onNext($0) }).disposed(by: rx.disposeBag)
    }

    func analytics(_ paymentCard: PaymentCard, date: Date? = nil) {
        navigate(to: CardAnalyticsCoordinator(root: self.root, container: container, card: paymentCard, date: date)).subscribe().disposed(by: rx.disposeBag)
    }

    func topUp() {
//        self.coordinate(to: AddMoneyCoordinator(root: root)).subscribe().disposed(by: rx.disposeBag)
    }
    
    func myQrCode() {
//      coordinate(to: AddMoneyQRCodeCoordinator(root: navigationRoot, scanAllowed: true, tabBarRoot: self.root
//                                                )).subscribe().disposed(by: rx.disposeBag)
    }

    func navigateToEIDScan() {
//        coordinate(to: EIDScanCoordinator(root: navigationRoot, eidScanType: .update)).subscribe(onNext: { [weak self] in
//            if case let ResultType.success(result) = $0 {
//                self?.navigateToInformationReview(result)
//            }
//        }).disposed(by: disposeBag)
    }

   /* func navigateToInformationReview(_ info: IdentityScannerResult) {
        coordinate(to: EIDInformationReviewCoordinatorPresentable(root: navigationRoot, identityInfo: info, canRescan: true))
            .subscribe(onNext: { [weak self] in
                if case let ResultType.success(result) = $0 {
                    if result == .rescan {
                        self?.navigateToEIDScan()
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    func navigateToGuidedTour(tourGuide: [GuidedTour],
                              skipObserver: AnyObserver<TourGuideView>,
                              completionObserver: AnyObserver<TourGuideView>) {
        self.coordinate(to: GuidedTourCoordinator(root: root, tours: tourGuide))
            .subscribe(onNext: { [weak self] result in
                guard let `self` = self else { return }
                self.checkIsGraphAvailable.onNext(())
                let view = tourGuide.count > 1 ? TourGuideView.dashboard : .dashboardGraph
                if case ResultType.cancel = result {
                    skipObserver.onNext(view)
                } else {
                    completionObserver.onNext(view)
                }
            })
            .disposed(by: disposeBag)
    } */

    func navigateToHelpAndSupport() {
//        coordinate(to: HelpAndSupportCoordinator(root: root)).subscribe().disposed(by: disposeBag)
    }
    
    func navigateToSendMoney(root: UITabBarController) {
      /*  coordinate(to: SendMoneyDashboardCoordinator(root: root, contactsManager: self.contactsManager)).subscribe(onNext: { result in
            if case ResultType.success = result {
                root.dismiss(animated: true, completion: nil)
                (root as UITabBarController).selectedIndex = 0
            }
        }).disposed(by: rx.disposeBag) */
    }

    func navigateToDeliveryStatus(_ card: PaymentCard) {
       /* let viewModel = CardDeliveryStatusViewModel(paymentCard: card)
        let viewController = CardDeliveryStatusViewController(viewModel: viewModel)
        let navigationController = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)

        viewModel.outputs.action.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            navigationController.dismiss(animated: true) { [unowned self] in
                self.navigateToSetPin(card: card)
            }
        }).disposed(by: disposeBag)

        navigationRoot.present(navigationController, animated: true, completion: nil) */
    }

    private func additionalInformation() {
//        coordinate(to: AdditionalInformationCoordinator(root: root.navigationController!)).subscribe().disposed(by: disposeBag)
    }
    
    func payBills(_ root: UIViewController){
//        AppAnalytics.shared.pauseSessionRecording()
//        coordinate(to: BillPaymentsHomeCoordinator(root: root)).subscribe(onNext: { _ in
//            AppAnalytics.shared.resumeSessionRecording()
//        }).disposed(by: disposeBag)
    }
    
    func navigateToAmendment() {
//        coordinate(to: B2CKYCAmendmentCoordinator(root: navigationRoot)).subscribe(onNext: { [weak self] _ in
//            self?.root.dismiss(animated: true, completion: nil)
//        }).disposed(by: disposeBag)
    }
    
    func navigateToProfile() {
       
//        coordinate(to: UserProfileCoordinator(navigationController: root, customer: container.accountProvider.current.map{ $0?.customer }.unwrap()))
//            .subscribe(onNext: { result in
//
//            }).disposed(by: rx.disposeBag)
        
        coordinate(to: UserProfileCoordinator(root: root, container: self.container))
            .subscribe()
            .disposed(by: rx.disposeBag)
        
//        coordinate(to: SendMoneyDashboardCoordinator(root: root, container: self.container, contactsManager: self.contactsManager, repository: container.makeY2YRepository())).subscribe(onNext: { result in
//            if case ResultType.success = result {
//                root.dismiss(animated: true, completion: nil)
//                (root as? UITabBarController)?.selectedIndex = 0
//            }
//        }).disposed(by: rx.disposeBag)

    }
    
    fileprivate func sendMoney(_ root: UIViewController) {
        coordinate(to: SendMoneyDashboardCoordinator(root: root, container: self.container, contactsManager: self.contactsManager, repository: container.makeY2YRepository())).subscribe(onNext: { result in
            if case ResultType.success = result {
                root.dismiss(animated: true, completion: nil)
                (root as? UITabBarController)?.selectedIndex = 0
            }
        }).disposed(by: rx.disposeBag)
    }
    
    private func topup(_ root: UIViewController, returnsToDashboard: Bool = true, successButtonTitle: String? = nil) {
        let rootNav = returnsToDashboard ? root : root.lastPresentedViewController ?? root
        coordinate(to: AddMoneyCoordinator(root: rootNav, container: self.container, contactsManager: self.contactsManager, repository: container.makeY2YRepository())).subscribe(onNext: { result in
            if case ResultType.success = result, returnsToDashboard {
                (root as? UITabBarController)?.selectedIndex = 0
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func navigateToAddMoneyQRCode() {
        self.root.tabBar.isHidden = true
        navigate(to: AddMoneyQRCodeCoordinator(root: navigationRoot, scanAllowed: true, container: container)).subscribe(onNext: { [weak self] _  in
            self?.root.tabBar.isHidden = false
        }).disposed(by: rx.disposeBag)
    }
    
    
}
