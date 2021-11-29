//
//  CardsCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPCore

public class CardsCoordinator: Coordinator<ResultType<Void>> {

    private let root: UITabBarController
    private let result = PublishSubject<ResultType<Void>>()
    private var navigationRoot: UINavigationController!
    private var container: UserSessionContainer!

    public init(root: UITabBarController, container: UserSessionContainer) {
        self.root = root
        self.container = container

        super.init()

        self.navigationRoot = makeNavigationController()
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let accountProvider = container.accountProvider
        let cardsRepository = container.makeCardsRepository()
        let viewController = CardsViewController(themeService: container.themeService, viewModel: CardsViewModel(accountProvider: accountProvider, cardsRepository: cardsRepository))

        navigationRoot.pushViewController(viewController, animated: false)
        navigationRoot.tabBarItem = UITabBarItem(title: "Cards",
                                                 image: UIImage(named: "icon_tabbar_cards", in: .yapPakistan),
                                                 selectedImage: nil)

        if root.viewControllers == nil {
            root.viewControllers = [navigationRoot]
        } else {
            root.viewControllers?.append(navigationRoot)
        }

        viewController.viewModel.outputs.details.withUnretained(self)
            .subscribe(onNext: { $0.0.detailScreen(status: $0.1.deliveryStatus, cardSerial: $0.1.cardSerial ?? "") })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.eyeInfo.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.cardDetailBottomVC() })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.cardDetails.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.cardDetailView() })
            .disposed(by: rx.disposeBag)

        return result
    }

    func cardDetailView() {
        let viewModel = CardDetailViewModel()
        let viewController = CardDetailViewController(viewModel: viewModel, themeService: container.themeService)
        viewController.hidesBottomBarWhenPushed = true
        navigationRoot.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.navigationRoot.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.details.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.detailPopUpVC() })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.limit.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.cardLimits() })
            .disposed(by: rx.disposeBag)
    }

    func cardLimits() {
        let strings = LimitsViewModel.ResourcesType(
            title: "Set limits",
            cellsData: [("ATM withdrawl", "Allow your card to withdraw from cash machines", isOn: true),
                        ("Retail payments", "Allow your card to be used at retail outlets", isOn: true)]
        )
        let viewModel = LimitsViewModel(strings: strings)
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

    func detailPopUpVC() {
        let resources = CardDetailPopUpViewModel.ResourcesType(
            cardImage: "payment_card",
            closeImage: "x",
            titleLabel: "Primary card",
            subTitleLabel: "Primary card",
            numberTitleLabel: "Card number",
            numberLabel: "2233442323210102",
            dateTitleLabel: "Expire date",
            dateLabel: "11/26",
            cvvTitleLabel: "CVV",
            cvvLabel: "145",
            copyButtonTitle: "copy")
        let viewModel = CardDetailPopUpViewModel(resources: resources)
        let viewController = CardDetailPopUpViewController(viewModel: viewModel, themeService: container.themeService)
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        navigationRoot.present(viewController, animated: true, completion: nil)

        viewModel.close.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.navigationRoot.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }

    func cardDetailBottomVC() {
        let resources = CardDetailBottomViewModel.ResourcesType(
            titleLabel: "Primary card details",
            numberTitleLabel: "Card number",
            numberLabel: "2233000230033",
            dateTitleLabel: "Expiry date",
            dateLabel: "11/26",
            cvvTitleLabel: "CVV",
            cvvLabel: "143",
            copyButtonTitle: "copy"
        )
        let viewModel = CardDetailBottomViewModel(resources: resources)
        let viewController = CardDetailBottomViewController(viewModel: viewModel, themeService: container.themeService)
        viewController.modalPresentationStyle = .overCurrentContext
        navigationRoot.present(viewController, animated: true, completion: nil)

        viewModel.outputs.close.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.navigationRoot.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }

    func detailScreen(status: DeliveryStatus, cardSerial: String) {
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
