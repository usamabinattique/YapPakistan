//
//  ReorderCardCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 29/12/2021.
//

import RxSwift
import YAPCore

public class ReorderCardCoordinator: Coordinator<ResultType<Void>> {

    private let root: UIViewController
    private let result = PublishSubject<ResultType<Void>>()
    private var navigationRoot: UINavigationController!
    private var container: UserSessionContainer!

    var cardDetaild: PaymentCard?; #warning("FIXME")

    init(root: UIViewController,
                container: UserSessionContainer,
                cardDetaild: PaymentCard) {
        self.root = root
        self.container = container
        self.cardDetaild = cardDetaild

        super.init()

        self.navigationRoot = makeNavigationController()
    }
    
    public override var feature: PKCoordinatorFeature { .reorderCard } 

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        let viewController = ReorderCardModuleBuilder(
            container: self.container,
            serialNumber: self.cardDetaild?.cardSerialNumber ?? "",
            repository: container.makeCardsRepository()
        ).viewController()

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.navigationRoot.dismiss(animated: true, completion: nil)
                self.result.onNext(.success(()))
                self.result.onCompleted()
            })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.reorderSuccess() })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.editAddress.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.editAddress() })
            .disposed(by: rx.disposeBag)

        self.navigationRoot.pushViewController(viewController)
        self.navigationRoot.modalPresentationStyle = .fullScreen
        self.root.present(navigationRoot, animated: true, completion: nil)

        return result
    }

    fileprivate func reorderSuccess() {
        let viewController = ReorderSuccessModuleBuilder(container: self.container).viewController()
        self.navigationRoot.pushViewController(viewController)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.navigationRoot.dismiss(animated: true, completion: nil)
                self.result.onNext(.success(()))
                self.result.onCompleted()
            })
            .disposed(by: rx.disposeBag)
    }

    fileprivate func editAddress() {
        let container = KYCFeatureContainer(parent: self.container)

        let viewController = ReorderAddressModuleBuilder(container: container).viewController()
        self.navigationRoot.pushViewController(viewController)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigationRoot.popViewController() })
            .disposed(by: rx.disposeBag)

        let citySelected = viewController.viewModel.outputs.city.withUnretained(self)
            .flatMap{ `self`, _ in self.selectCityName() }
            .share()
        citySelected.bind(to: viewController.viewModel.inputs.citySelectObserver)
            .disposed(by: rx.disposeBag)
        citySelected.subscribe(onNext: { [unowned self] _ in self.navigationRoot.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)
    }

    func selectCityName() -> Observable<String>  {
        let viewController = container.makeCityListViewController()

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigationRoot.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        return viewController.viewModel.outputs.next
    }
}

// MARK: - Helpers
extension ReorderCardCoordinator {
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
