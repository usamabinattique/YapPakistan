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

        self.makeNavigationController()
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let accountProvider = container.accountProvider
        let cardsRepository = container.makeCardsRepository()
        let viewController = CardsViewController(themeService: container.themeService, viewModel: CardsViewModel(accountProvider: accountProvider, cardsRepository: cardsRepository))

        viewController.viewModel.outputs.details.withUnretained(self)
            .subscribe(onNext: { $0.0.detailScreen(status: $0.1.deliveryStatus, cardSerial: $0.1.cardSerial ?? "") })
            .disposed(by: rx.disposeBag)

        navigationRoot.pushViewController(viewController, animated: false)
        navigationRoot.tabBarItem = UITabBarItem(title: "Cards",
                                                 image: UIImage(named: "icon_tabbar_cards", in: .yapPakistan),
                                                 selectedImage: nil)

        if root.viewControllers == nil {
            root.viewControllers = [navigationRoot]
        } else {
            root.viewControllers?.append(navigationRoot)
        }

        return result
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

    func makeNavigationController() {
        navigationRoot = UINavigationController()
        navigationRoot.interactivePopGestureRecognizer?.isEnabled = false
        navigationRoot.navigationBar.isTranslucent = true
        navigationRoot.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationRoot.navigationBar.shadowImage = UIImage()
        navigationRoot.setNavigationBarHidden(false, animated: true)
    }
}
