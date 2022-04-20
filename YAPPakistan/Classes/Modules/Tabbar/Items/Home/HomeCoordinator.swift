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
        
        transactionCategoryResult.bind(to: viewController.viewModel.inputs.categoryChangedObserver).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.menuTap.subscribe(onNext: { [weak self] in
            (self?.root as? MenuViewController)?.showMenu()
        }).disposed(by: rx.disposeBag)

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
                    self.root.setViewControllers([self.navigationRoot.viewControllers[0]], animated: true)
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
        let name = Notification.Name.init(.logout)
        NotificationCenter.default.post(name: name,object: nil)
    }
}

//MARK: Search
extension HomeCoodinator {
    func navigateToSearch(card: PaymentCard?) {
        /*let coordinator = SearchTransactionsCoordinator(card: card, root: root,container: container)
        
        coordinate(to: coordinator).subscribe(onNext: {[weak self] result in
            if !(result.isCancel) {
                self?.transactionCategoryResult.onNext(())
            }
        }).disposed(by: rx.disposeBag) */
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
