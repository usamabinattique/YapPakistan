//
//  YAPTabbarCoordinator.swift
//  YAP
//
//  Created by Muhammad Hussaan Saeed on 21/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPKit
import RxSwift
import More
import Cards
import SendMoney
import YapToYap
import OnBoarding
import AppAnalytics
import CardScanner

public class YAPTabbarCoordinator: Coordinator<ResultType<DashboardResult>> {

    private let window: UIWindow
    private let result = PublishSubject<ResultType<DashboardResult>>()
    private var partnerBankStatus: PartnerBankStatus?
    private var mainViewController: YAPTabbarController!
    private let topupInitiationSubject = PublishSubject<String>()
    private let transactionProvider: PaymentCardTransactionProvider
    private let tourGuideRepository: TourGuideRepository
    private let moreRepository: MoreRepository
    private let moreCoordination = PublishSubject<MoreExternalCoordinationType>()
    private let notificationManager: InAppNotificationManager
    private var rootNavigationController: UINavigationController!

    public init(window: UIWindow,
                transactionProvider: PaymentCardTransactionProvider,
                tourGuideRepository: TourGuideRepository,
                moreRepository: MoreRepository,
                notificationManager: InAppNotificationManager = .shared) {
        self.window = window
        self.transactionProvider = transactionProvider
        self.tourGuideRepository = tourGuideRepository
        self.moreRepository = moreRepository
        self.notificationManager = notificationManager
    }

    public override func start() -> Observable<ResultType<DashboardResult>> {
        let restrictions = SessionManager.current.currentProfile?.restrictions ?? []

        let restrictionCount = restrictions.filter({ ![.debitCardPinBlocked, .accountInactive, .none].contains($0) }).count

        if restrictionCount > 0 {
            openOTPBlock(restriction: restrictions.first!)
        } else {
            makeTabbar()
        }

        initiateCardDetails()
        initiateAddMoney()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnteredForeground), name: .ApplicationDidBecomeActive, object: nil)
        applicationEnteredForeground()

        return result.do(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            NotificationCenter.default.removeObserver(self) })
    }
}

extension YAPTabbarCoordinator {

    func makeTabbar() {
        let viewController = YAPTabbarController()
        mainViewController = viewController

        let menuViewModel = SideMenuViewModel()
        let menuViewController = SideMenuViewController(viewModel: menuViewModel)
        viewController.menuWidth = 0.85
        viewController.menu = menuViewController

        home(root: viewController, notificationManager: notificationManager)
        store(root: viewController)

        let yapit = UIViewController()
        yapit.view.backgroundColor = .white
        yapit.tabBarItem = UITabBarItem(title: "YAP it", image: nil, selectedImage: nil)
        viewController.viewControllers?.append(yapit)

        cards(root: viewController)
        more(root: viewController, notificationManager: notificationManager)

        let navController = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
        rootNavigationController = navController
        navController.setNavigationBarHidden(true, animated: false)
        window.rootViewController = navController
        window.makeKeyAndVisible()

        viewController.button.rx.tap.subscribe(onNext: { [unowned self] in self.yapIt(root: viewController, height: viewController.tabBar.bounds.height)}).disposed(by: disposeBag)

        SessionManager.current.currentAccount.subscribe(onNext: { [weak self] in self?.partnerBankStatus = $0?.parnterBankStatus }).disposed(by: disposeBag)

        NotificationCenter.default.addObserver(self, selector: #selector(backToDashbaordObsever), name: .goToDashbaord, object: nil)

        menuViewModel.outputs.menuItemSelected
            .withLatestFrom(Observable.combineLatest(CardsManager.shared.cards.map{ $0.filter{ $0.cardType == .debit }.first }.unwrap(), menuViewModel.outputs.menuItemSelected))
            .subscribe(onNext: { [weak self] paymentCard, menuItem in
                guard let self = self else { return }
                viewController.hideMenu()
                DispatchQueue.main.async {
                    switch menuItem {
                    case .analytics:
                        AppAnalytics.shared.logEvent(MainMenuEvent.tapAnalytics())
                        self.analytics(viewController, paymentCard: paymentCard)
                    case .help, .contact:
                        AppAnalytics.shared.logEvent(MainMenuEvent.tapHelp())
                        self.helpAndSupport(viewController)
                    case .statements:
                        AppAnalytics.shared.logEvent(MainMenuEvent.tapStatements())
                        self.statements(viewController)
                    case .referFriend:
                        AppAnalytics.shared.logEvent(MainMenuEvent.tapReferFriend())
                        self.inviteFriend(viewController)
                    case .housholdSalary:
                        self.householdSalary(viewController)
                    case .chat:
                        AppAnalytics.shared.logEvent(MainMenuEvent.tapLivechat())
                        ChatManager.shared.openChat()
                    case .notifications:
                        AppAnalytics.shared.logEvent(MainMenuEvent.tapAlerts())
                    case .qrCode:
                        self.myQrCode(self.rootNavigationController)
                    default:
                        break
                    }
                }}).disposed(by: disposeBag)

        menuViewModel.outputs.settings.subscribe(onNext: { [weak self] _ in
            self?.settings(viewController)
        }).disposed(by: disposeBag)

        menuViewModel.outputs.switchAccount.subscribe(onNext: { [weak self] in
            self?.result.onNext(.success(.switchAccount))
            self?.result.onCompleted()
        }).disposed(by: disposeBag)

        topupInitiationSubject.subscribe(onNext: { [unowned self] in
            self.topup(viewController, returnsToDashboard: false, successButtonTitle: $0)
        }).disposed(by: disposeBag)

        menuViewModel.outputs.result.subscribe(onNext: {[weak self] in
            logoutYAPUser()
            self?.result.onNext(.success(.logout))
            self?.result.onCompleted()
        }).disposed(by: disposeBag)

        menuViewModel.outputs.openProfile.subscribe(onNext: {[weak self] _ in
            AppAnalytics.shared.logEvent(MainMenuEvent.tapProfile())
            self?.settings(viewController)
        }).disposed(by: disposeBag)

        menuViewModel.outputs.shareAccountInfo.subscribe(onNext: { [weak self] accountInfo in
            viewController.hideMenuWithCompletion { [weak self] in
                DispatchQueue.main.async { self?.share(accountInfo: accountInfo, root: viewController) }
            }
        }).disposed(by: disposeBag)
    }

    func openOTPBlock(restriction: UserAccessRestriction) {
        let viewModel = OTPBlockedViewModel(restriction)
        let viewController = OTPBlockedViewController(with: viewModel)

        viewModel.outputs.goToDashboard.subscribe(onNext: { [weak self] _ in
            self?.makeTabbar()
        }).disposed(by: disposeBag)

        let navController = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
        navController.setNavigationBarHidden(true, animated: false)
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }

    @objc
    func backToDashbaordObsever() {
        mainViewController.navigationController?.dismiss(animated: true, completion: nil)
        mainViewController.selectedIndex = 0
    }


    fileprivate func home(root: UITabBarController, notificationManager: InAppNotificationManager) {
        self.coordinate(to: HomeCoordinator(root: root,
                                            tourGuideRepository: tourGuideRepository,
                                            moreRepository: moreRepository,
                                            notificationManager: notificationManager)).subscribe(onNext: { [weak self] in
            if case ResultType.success = $0 {
                self?.result.onNext(.success(.switchAccount))
                self?.result.onCompleted()
            }
        }).disposed(by: disposeBag)
    }

    fileprivate func store(root: UITabBarController) {
        self.coordinate(to: StoreCoordinator(root: root, transactionProvider: transactionProvider, tourGuideRepository: tourGuideRepository)).subscribe().disposed(by: disposeBag)
    }

    fileprivate func cards(root: UITabBarController) {
        self.coordinate(to: CardsCoordinator(root: root,
                                             topUpFlowIntiationObserver: topupInitiationSubject.asObserver(),
                                             repository: CardsRepository(),
                                             tourGuideRepository: tourGuideRepository))
            .subscribe().disposed(by: disposeBag)
    }

    fileprivate func more(root: UITabBarController, notificationManager: InAppNotificationManager) {
        self.coordinate(to: MoreCoordinator(root: root,
                                            tourGuideRepository: tourGuideRepository,
                                            repository: moreRepository,
                                            externalCoordination: moreCoordination.asObserver(),
                                            notificationManager: notificationManager))
            .subscribe(onNext: { [weak self] result in
            guard let `self` = self else { return }
            if case ResultType.success(UserProfileResult.logout) = result {
                self.result.onNext(.success(.logout))
                self.result.onCompleted()
            }
        }).disposed(by: disposeBag)

        moreCoordination.subscribe(onNext: { [weak self] in
            self?.moreExternalCoordination($0)
        }).disposed(by: disposeBag)
    }

    fileprivate func yapIt(root: UITabBarController, height: CGFloat) {
        coordinate(to: YAPItCoordinator(root: root, tabBarHeight: height)).subscribe(onNext: { [unowned self] in
            if case let ResultType.success(result) = $0 {
                switch result {
                case .sendMoney:
                    self.sendMoney(root)
                case .addMoney:
                    self.topup(root)
                case .payBills:
                    //                    self.y2y(root)
                    break
                }
            }
        }).disposed(by: disposeBag)
    }

    fileprivate func sendMoney(_ root: UIViewController) {
        coordinate(to: SendMoneyDashboardCoordinator(root: root)).subscribe(onNext: { result in
            if case ResultType.success = result {
                root.dismiss(animated: true, completion: nil)
                (root as? UITabBarController)?.selectedIndex = 0
            }
        }).disposed(by: disposeBag)
    }
    
    //    fileprivate func y2y(_ root: UIViewController) {
    //        let repository = Y2YRepository()
    //        coordinate(to: Y2YCoordinator.init(root: root, repository: repository)).subscribe(onNext: { result in
    //            if case ResultType.success = result {
    //                (root as? UITabBarController)?.selectedIndex = 0
    //            }
    //        }).disposed(by: disposeBag)
    //    }
    
    fileprivate func topup(_ root: UIViewController, returnsToDashboard: Bool = true, successButtonTitle: String? = nil) {
        let rootNav = returnsToDashboard ? root : root.lastPresentedViewController ?? root
        coordinate(to: AddMoneyCoordinator(root: rootNav, successButtonTitle: successButtonTitle)).subscribe(onNext: { result in
            if case ResultType.success = result, returnsToDashboard {
                (root as? UITabBarController)?.selectedIndex = 0
            }
        }).disposed(by: disposeBag)
    }

    private func analytics(_ root: UIViewController, paymentCard: PaymentCard) {
        coordinate(to: CardAnalyticsCoordinator(root: root, card: paymentCard)).subscribe().disposed(by: self.disposeBag)
    }

    private func helpAndSupport(_ root: UIViewController) {
        coordinate(to: HelpAndSupportCoordinator(root: root)).subscribe().disposed(by: disposeBag)
    }

    private func statements(_ root: UIViewController) {

        coordinate(to: StatementsCoordinator(root: root, card: SessionManager.current.currentProfile, repository: CardsRepository())).subscribe().disposed(by: self.disposeBag)
    }

    private func settings(_ root: UIViewController) {
        coordinate(to: UserProfileCoordinator(navigationController: root, customer: SessionManager.current.currentAccount.map{ $0?.customer }.unwrap()))
            .subscribe(onNext: { [weak self] in
                if case let ResultType.success(result) = $0 {
                    if result == .logout {
                        logoutYAPUser()
                        self?.result.onNext(ResultType.success(.logout))
                        self?.result.onCompleted()
                    }
                }
            }).disposed(by: disposeBag)
    }

    private func inviteFriend(_ root: UIViewController) {
        coordinate(to: InviteFriendCoordinator(root: root)).subscribe().disposed(by: disposeBag)
    }

    private func householdSalary(_ root: UIViewController) {

    }
    
    func myQrCode(_ root: UINavigationController) {
        coordinate(to: AddMoneyQRCodeCoordinator(root: root, scanAllowed: true)).subscribe().disposed(by: disposeBag)
    }
    
    func share(accountInfo: String, root: UIViewController) {
        let items = [accountInfo]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        root.present(activityVC, animated: true)
    }

    func initiateCardDetails() {
        Observable.combineLatest(NotificationCenter.default.rx.notification(.InvokeCardDetailsCoordinator),
                                 SessionManager.current.cards.map { $0.first(where: { $0.cardType == .debit })}.unwrap().distinctUntilChanged())
            .subscribe(onNext: { [weak self] (notification, paymentCard) in
                guard let params = notification.object as? (UIViewController, AnyObserver<Void>),
                    let `self` = self else { return }
                let coordinator = PaymentCardDetailCoordinatorPresentable(root: params.0,
                                                                          paymentCard: paymentCard,
                                                                          repository: CardsRepository(),
                                                                          tourGuideRepository: self.tourGuideRepository,
                                                                          topUpFlowInitiationObserver: self.topupInitiationSubject.asObserver())
                self.coordinate(to: coordinator).do(onNext: { _ in params.0.dismiss(animated: true); params.1.onNext(()) }).subscribe().disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }

    func initiateAddMoney() {
        NotificationCenter.default.rx.notification(.InvokeAddMoneyCoordinator)
            .subscribe(onNext: { [weak self] notification in
                guard let params = notification.object as? (UIViewController, AnyObserver<Void>),
                    let `self` = self else { return }
                let coordinator = AddMoneyCoordinator(root: params.0)
                self.coordinate(to: coordinator).do(onNext: { _ in params.1.onNext(()) }).subscribe().disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }

    @objc
    private func applicationEnteredForeground() {
        guard let flowID = ExternalFlowManager.externalFlowId else { return }
        coordinate(to: ExternalFlowCoordinator(root: rootNavigationController,
                                               tabBar: mainViewController,
                                               flow: ExternalFlow(rawValue: flowID) ?? .other,
                                               notificationManager: notificationManager,
                                               externalCoordination: moreCoordination))
            .subscribe().disposed(by: disposeBag)
    }
}

private extension YAPTabbarCoordinator {
    func moreExternalCoordination(_ coordination: MoreExternalCoordinationType) {
        var card: PaymentCard? = nil
        SessionManager.current.cards.map{ $0.filter{ $0.cardType == .debit }.first }.unwrap().subscribe(onNext: {
            card = $0
        }).disposed(by: disposeBag)
        switch coordination.feature {
        case .helpAndSupport:
            helpAndSupport(coordination.root)
        case .updateEID:
            navigateToEIDScan(root: coordination.root, resultObserver: coordination.resultObserver)
        case .b2cKyc:
            navigateToKYC(root: coordination.root, resultObserver: coordination.resultObserver)
        case .setPin:
            guard let card = card else { return }
            navigateToSetPin(card: card, root: coordination.root, resultObserver: coordination.resultObserver)
        default:
            break
        }
    }

    func navigateToKYC(root: UINavigationController, resultObserver: AnyObserver<ResultType<Void>>?) {
        coordinate(to: B2CKYCCoordinatorPresentable(root: root)).subscribe(onNext: {
            resultObserver?.onNext($0)
        }).disposed(by: disposeBag)
    }

    func navigateToEIDScan(root: UINavigationController, resultObserver: AnyObserver<ResultType<Void>>?) {
        coordinate(to: EIDScanCoordinator(root: root, eidScanType: .update)).subscribe(onNext: { [weak self] in
            if case let ResultType.success(result) = $0 {
                self?.navigateToInformationReview(result, root: root, resultObserver: resultObserver)
            } else {
                resultObserver?.onNext(.cancel)
            }
        }).disposed(by: disposeBag)
    }

    func navigateToInformationReview(_ info: IdentityScannerResult, root: UINavigationController, resultObserver: AnyObserver<ResultType<Void>>?) {
        coordinate(to: EIDInformationReviewCoordinatorPresentable(root: root, identityInfo: info, canRescan: true))
            .subscribe(onNext: { [weak self] in
                if case let ResultType.success(result) = $0 {
                    if result == .rescan {
                        self?.navigateToEIDScan(root: root, resultObserver: resultObserver)
                    } else {
                        resultObserver?.onNext(.success(()))
                    }
                } else {
                    resultObserver?.onNext(.cancel)
                }
            })
            .disposed(by: disposeBag)
    }

    func navigateToSetPin(card: PaymentCard, root: UINavigationController, resultObserver: AnyObserver<ResultType<Void>>?) {
        guard card.shouldSetPin else { return }
        coordinate(to: SetCardPINCoordinator(root: root, card: card)).subscribe(onNext: { [weak self] result in
            if case let ResultType.success(setPinResult) = result {
                root.dismiss(animated: true, completion: nil)

                if setPinResult == .topup {
                    self?.topUp(root: root, resultObserver: resultObserver)
                } else {
                    resultObserver?.onNext(.success(()))
                }
            } else {
                resultObserver?.onNext(.cancel)
            }
        }).disposed(by: disposeBag)
    }

    func topUp(root: UINavigationController, resultObserver: AnyObserver<ResultType<Void>>?) {
        self.coordinate(to: AddMoneyCoordinator(root: root)).subscribe(onNext: { _ in
            resultObserver?.onNext(.success(()))
        }).disposed(by: disposeBag)
    }
}
