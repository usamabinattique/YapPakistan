//
//  CardsCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPCore
import YAPComponents

public class CardsCoordinator: Coordinator<ResultType<Void>> {

    private let root: UITabBarController
    private let result = PublishSubject<ResultType<Void>>()
    private var navigationRoot: UINavigationController!
    private var container: UserSessionContainer!

    var cardDetaild: PaymentCard?; #warning("FIXME")

    public init(root: UITabBarController, container: UserSessionContainer) {
        self.root = root
        self.container = container

        super.init()

        self.navigationRoot = makeNavigationController()
//        self.navigationRoot =  UINavigationControllerFactory.createAppThemedNavigationController(root: self.root, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let accountProvider = container.accountProvider
        let cardsRepository = container.makeCardsRepository()
        let viewController = CardsViewController(themeService: container.themeService, viewModel: CardsViewModel(accountProvider: accountProvider, cardsRepository: cardsRepository))
      //  self.navigationRoot =  UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        
//      /  navigationRoot.tabBarItem = UITabBarItem(title: "Cards",
//                                                 image: UIImage(named: "icon_tabbar_cards", in: .yapPakistan),
//                                                 selectedImage: nil)
//
//        self.root.present(self.navigationRoot, animated: true, completion: nil)
        
        navigationRoot.pushViewController(viewController, animated: false)
        navigationRoot.tabBarItem = UITabBarItem(title: "Cards",
                                                 image: UIImage(named: "icon_tabbar_cards", in: .yapPakistan),
                                                 selectedImage: nil)

        if root.viewControllers == nil {
            root.viewControllers = [navigationRoot]
        } else {
            root.viewControllers?.append(navigationRoot)
        }

//        viewController.viewModel.outputs.deliveryDetails
//            .subscribe(onNext: { [weak self] card in self?.deleveryStatusScreen(card) })
//            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.eyeInfo.withUnretained(self)
            .subscribe(onNext: { `self`, card in self.cardDetailBottomVC(paymentCard: card) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.cardDetails.withUnretained(self)
            .subscribe(onNext: { `self`, card in
                if card?.pinCreated == true {
                    self.cardDetailView(card)
                } else {
                    self.deleveryStatusScreen(card)
                }
            })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.orderNew.unwrap().withUnretained(self)
            .subscribe(onNext: { `self`, card in self.orderNew(cardDetaild: card) })
            .disposed(by: rx.disposeBag)

        return result
    }

    func orderNew(cardDetaild: PaymentCard) {
        let coordinator = ReorderCardCoordinator(root: navigationRoot,
                                                 container: self.container,
                                                 cardDetaild: cardDetaild)
        coordinate(to: coordinator).subscribe().disposed(by: rx.disposeBag)
    }

    func cardDetailView(_ paymentCard: PaymentCard?) {
        cardDetaild = paymentCard; #warning("FIXME")

        let tProvider = DebitCardTransactionsProvider(repository: container.makeTransactionsRepository())
        let tviewModel = TransactionsViewModel.init(transactionDataProvider: tProvider,
                                               cardSerialNumber: paymentCard?.cardSerialNumber ?? "",
                                               debitSearch: true)
        // let tviewModel = TransactionsViewModel(cardSerialNumber: paymentCard?.cardSerialNumber)
        let tviewController = TransactionsViewController(
            viewModel: tviewModel, themeService: container.themeService)

        let viewModel = CardDetailViewModel(paymentCard: paymentCard, repository: container.makeCardsRepository())
        let viewController = CardDetailViewController(transactionViewController: tviewController, viewModel: viewModel, themeService: container.themeService)
        viewController.hidesBottomBarWhenPushed = true
        navigationRoot.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.navigationRoot.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.details.withUnretained(self)
            .subscribe(onNext: { `self`, card in self.detailPopUpVC(card) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.limit.withUnretained(self)
            .subscribe(onNext: { `self`, card in self.cardLimits(card) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.options.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.cardOptions() })
            .disposed(by: rx.disposeBag)

        viewController.transactionViewController.viewModel.outputs
            .openFilter.withLatestFrom(viewModel.outputs.filter).withUnretained(self)
            .subscribe(onNext: {
                `self`, filter in
                
                self.openFilter(filter: filter,detailViewModel: viewModel)
                
            })
            .disposed(by: rx.disposeBag)
    }

    func openFilter(filter: TransactionFilter? = nil, detailViewModel: CardDetailViewModel) {
        let viewModel = TransactionFilterViewModel(filter,repository: container.makeTransactionsRepository())
        let filterView = TransactionFilterViewController(viewModel: viewModel, themeService: container.themeService)
 /*       navigationRoot.setNavigationBarHidden(false, animated: false)
        filterView.modalPresentationStyle = .fullScreen */
//        navigationRoot.setNavigationBarHidden(false, animated: true)
//        self.navigationRoot.pushViewController(filterView)
     /*   self.navigationRoot.present(filterView, animated: true, completion: nil) */
        
        
        let nav =  UINavigationControllerFactory.createAppThemedNavigationController(root: filterView, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
//
        
       
        self.navigationRoot.present(nav, animated: true, completion: nil)
        
        viewModel.outputs.result.withUnretained(self).subscribe(onNext: { (`self`, filter) in
            if  let cardDetail = self.navigationRoot.viewControllers.last as? CardDetailViewController {
                if let vm = cardDetail.transactionViewController.viewModel as? TransactionsViewModel {
                    vm.filterSelected.onNext(filter)
                }
            }
            detailViewModel.filterObserver.onNext(filter)
        }).disposed(by: rx.disposeBag)

    }

    func cardOptions() {
        let cardOptions = CardOptionsModuleBuilder().viewController()
        cardOptions.viewModel.outputs.tapIndex.withUnretained(self) // Change Pin flow
            .subscribe(onNext: { `self`, index in
                switch index {
                case 0: self.changeCardName(cardDetaild: self.cardDetaild)
                case 1: self.changePin(cardDetaild: self.cardDetaild)
                case 2: self.forgotPin(cardDetaild: self.cardDetaild)
                case 3: break   //View statement pending
                case 4: self.reportLostCard(cardDetaild: self.cardDetaild!)
                default: break
                }
            })
            .disposed(by: rx.disposeBag)
        self.navigationRoot.present(cardOptions, animated: true, completion: nil)
    }

    func changeCardName(cardDetaild: PaymentCard?) {
        let viewController = ChangeCardNameModuleBuilder(
            container: container,
            serialNumber: cardDetaild?.cardSerialNumber ?? "",
            currentName: cardDetaild?.cardName ?? "",
            repository: container.makeCardsRepository()).viewController()
        self.navigationRoot.pushViewController(viewController)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigationRoot.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .do(onNext: { `self`, _ in self.navigationRoot.popViewController() })
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { `self`, newName in self.updateName(newName: newName) })
            .disposed(by: rx.disposeBag)
    }

    func changePin(cardDetaild: PaymentCard?) {
        let coordinator = ChangePinCoordinator(root: self.navigationRoot, container: self.container, serialNumber: cardDetaild?.cardSerialNumber ?? "")

        let forgotResult = coordinate(to: coordinator)
            .filter{ $0.isSuccess == .forgotPin }.share()
        forgotResult.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.forgotPin(cardDetaild: cardDetaild) })
            .disposed(by: rx.disposeBag)
        forgotResult.withUnretained(self)
            .delay(.milliseconds(400), scheduler: MainScheduler.instance)
            .subscribe(onNext: { `self`, _ in
                let count = self.navigationRoot.viewControllers.count
                self.navigationRoot.viewControllers.remove(at: count - 2)
            })
            .disposed(by: rx.disposeBag)
    }

    func forgotPin(cardDetaild: PaymentCard?) {
        let coordinator = ForgotPinCoordinator(root: self.navigationRoot, container: self.container, serialNumber: cardDetaild?.cardSerialNumber ?? "")
        coordinate(to: coordinator).subscribe().disposed(by: rx.disposeBag)
    }
    
    func reportLostCard(cardDetaild: PaymentCard) {
        let coordinator = ReportCardCoordinator(root: self.navigationRoot, container: self.container, cardDetail: cardDetaild)
        coordinate(to: coordinator).subscribe().disposed(by: rx.disposeBag)
    }

    func cardLimits(_ paymentCard: PaymentCard) {
        let strings = LimitsViewModel.ResourcesType(
            title: "Set limits",
            cellsData: [
                ("ATM withdrawl", "Allow your card to withdraw from cash machines", isOn: true),
                ("Retail payments", "Allow your card to be used at retail outlets", isOn: true)
            ]
        )
        let viewModel = LimitsViewModel(strings: strings, paymentCard: paymentCard, repository: container.makeCardsRepository())
        let viewController = LimitsViewController(themeService: container.themeService, viewModel: viewModel)

        let navigation = makeNavigationController(viewController)
        navigation.modalPresentationStyle = .fullScreen

        navigationRoot.present(navigation, animated: true, completion: nil)

        viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.navigationRoot.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)

    }

    func detailPopUpVC(_ paymentCard: PaymentCard) {
        let resources = CardDetailPopUpViewModel.ResourcesType(
            cardImage: "payment_card",
            closeImage: "icon_close",
            titleLabel: "Primary card",
            subTitleLabel: "Primary card",
            numberTitleLabel: "Card number",
            numberLabel: "-",
            dateTitleLabel: "Expire date",
            dateLabel: "-",
            cvvTitleLabel: "CVV",
            cvvLabel: "-",
            copyButtonTitle: "copy")
        let viewModel = CardDetailPopUpViewModel(resources: resources,
                                                 repository: container.makeCardsRepository(),
                                                 paymentCard: paymentCard)
        let viewController = CardDetailPopUpViewController(viewModel: viewModel, themeService: container.themeService)
        
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        
        navigationRoot.present(viewController, animated: true, completion: nil)

        viewModel.close.withUnretained(self)
            .subscribe(onNext: { `self`,_ in
                self.navigationRoot.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }

    func cardDetailBottomVC(paymentCard: PaymentCard) {
        let resources = CardDetailBottomViewModel.ResourcesType(
            titleLabel: "Primary card details",
            numberTitleLabel: "Card number",
            numberLabel: "-",
            dateTitleLabel: "Expiry date",
            dateLabel: "-",
            cvvTitleLabel: "CVV",
            cvvLabel: "-",
            copyButtonTitle: "copy"
        )
        let viewModel = CardDetailBottomViewModel(resources: resources,
                                                  repository: container.makeCardsRepository(),
                                                  paymentCard: paymentCard)
        let viewController = CardDetailBottomViewController(viewModel: viewModel, themeService: container.themeService)
        viewController.modalPresentationStyle = .overCurrentContext
        navigationRoot.tabBarController?.tabBar.isHidden = true
        navigationRoot.present(viewController, animated: true, completion: nil)

        viewModel.outputs.close.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.navigationRoot.dismiss(animated: true) {
                    self.navigationRoot.tabBarController?.tabBar.isHidden = false
                }
            })
            .disposed(by: rx.disposeBag)
    }

    func deleveryStatusScreen(_ card: PaymentCard?) {
        let status = card?.deliveryStatus ?? .ordering
        let cardSerial = card?.cardSerialNumber ?? ""

        let viewController = CardStatusModuleBuilder(container: self.container, status: status).viewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationRoot.pushViewController(viewController)

        viewController.viewModel.outputs.next.filter({ _ in true /* $0 > 0 */ }).withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.setPinIntroScreen(cardSerial: cardSerial) })
            .disposed(by: rx.disposeBag)
        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigationRoot.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)
    }

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

// MARK: - Helpers
extension CardsCoordinator {

    func updateName(newName: String) { #warning("FIXME")
        guard let viewController = self.navigationRoot.topViewController as? CardDetailViewController
        else { return }
        viewController.viewModel.inputs.newName.onNext(newName)
    }

    func makeNavigationController(_ root: UIViewController? = nil) -> UINavigationController {

        var navigation: UINavigationController!
        if let root = root {
            navigation = UINavigationController(rootViewController: root)
        } else {
            navigation = UINavigationController()
        }
        navigation.interactivePopGestureRecognizer?.isEnabled = false
        navigation.navigationBar.isTranslucent = true
        navigation.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigation.navigationBar.shadowImage = UIImage()
        navigation.setNavigationBarHidden(false, animated: true)

        return navigation
    }
}
