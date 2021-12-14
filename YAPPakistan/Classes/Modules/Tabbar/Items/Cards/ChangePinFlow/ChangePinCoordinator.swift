//
//  ChangePinCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/12/2021.
//

import RxSwift
import YAPCore

public class ChangePinCoordinator: Coordinator<ResultType<Void>> {

    private var container: UserSessionContainer!
    private let root: UINavigationController
    private let result = PublishSubject<ResultType<Void>>()
    private lazy var navigationRoot: UINavigationController = root // makeNavigationController()
    let serialNumber: String
    var oldPin: String = ""

    public init(root: UINavigationController, container: UserSessionContainer, serialNumber: String) {
        self.root = root
        self.container = container
        self.serialNumber = serialNumber
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        verifyOldPin()

        // root.present(navigationRoot, animated: true, completion: nil)
        return result
    }

    func verifyOldPin() {
        let viewController = VerifyCurrentPinModuleBuilder(cardSerialNumber: serialNumber, container: container)
            .viewController()
        navigationRoot.pushViewController(viewController)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.root.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { `self`, oldPin in
                self.newPin()
                self.oldPin = oldPin
            })
            .disposed(by: rx.disposeBag)
    }

    func newPin() {
        let viewController = NewPinModuleBuilder(container: container).viewController()
        navigationRoot.pushViewController(viewController)

        Observable.just(()).delay(.milliseconds(400), scheduler: MainScheduler.instance).withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.removeSecondLastViewController() })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigationRoot.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { `self`, pin in self.confirmNewPin(newPin: pin) })
            .disposed(by: rx.disposeBag)
    }

    func confirmNewPin(newPin: String) {
        let viewController = NewPinConfirmModuleBuilder(cardSerialNumber: serialNumber,
                                                        oldPin: oldPin,
                                                        newPin: newPin,
                                                        container: container).viewController()
        navigationRoot.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigationRoot.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.success() })
            .disposed(by: rx.disposeBag)
    }

    func success() {
        let viewController = PinChangeSuccessModuleBuilder(container: container).viewController()
        navigationRoot.pushViewController(viewController)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.popToRootViewController() })
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - Helpers
fileprivate extension ChangePinCoordinator {

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

    func removeSecondLastViewController() {
        let count = self.navigationRoot.viewControllers.count
        self.navigationRoot.viewControllers.remove(at: count - 2)
    }

    func popToRootViewController() {
        let count = self.navigationRoot.viewControllers.count
        let viewControllers = Array(self.navigationRoot.viewControllers[0..<(count - 3)])
        self.root.setViewControllers(viewControllers, animated: true)
    }
}
