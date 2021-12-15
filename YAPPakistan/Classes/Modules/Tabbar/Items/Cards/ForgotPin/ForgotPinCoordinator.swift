//
//  ForgotPinCoordinator.swift
//  Adjust
//
//  Created by Sarmad on 12/12/2021.
//

import RxSwift
import YAPCore

public class ForgotPinCoordinator: Coordinator<ResultType<Void>> {

    private var container: UserSessionContainer!
    private let root: UINavigationController
    private let result = PublishSubject<ResultType<Void>>()

    var serialNumber: String
    var passCode: String!

    public init(root: UINavigationController, container: UserSessionContainer, serialNumber: String) {
        self.root = root
        self.container = container
        self.serialNumber = serialNumber
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        verifyPasscode()

        // root.present(navigationRoot, animated: true, completion: nil)
        return result
    }

    func verifyPasscode() {
        let viewController = FPPassCodeModuleBuilder(cardSerialNumber: "", container: container).viewController()
        root.pushViewController(viewController)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.root.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { `self`, passCode in self.newPin(passCode: passCode) })
            .disposed(by: rx.disposeBag)
    }

    func newPin(passCode: String) {
        self.passCode = passCode

        let viewController = FPNewPinModuleBuilder(cardSerialNumber: serialNumber,
                                                   container: container).viewController()
        root.pushViewController(viewController)

        Observable.just(()).delay(.milliseconds(400), scheduler: MainScheduler.instance).withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.removeSecondLastViewController() })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.root.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { `self`, newPin in self.confirmNewPin(newPin: newPin) })
            .disposed(by: rx.disposeBag)
    }

    func confirmNewPin(newPin: String) {
        let viewController = FPNewPinConfirmModuleBuilder(
            cardSerialNumber: serialNumber,
            passCode: passCode,
            newPin: newPin,
            container: self.container).viewController()
        root.pushViewController(viewController)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.root.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.verifyOTP.withUnretained(self)
            .flatMap{ `self`, _ in self.verifyPinChange() }.share()
            .bind(to: viewController.viewModel.inputs.otpTokenObserver)
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self).share()
            .subscribe(onNext: { `self`, _ in self.success() })
            .disposed(by: rx.disposeBag)
    }

    func verifyPinChange() -> Observable<String> {
        let viewController = VerifyPinChangeModuleBuilder(container: container).viewController()
        root.pushViewController(viewController)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.root.popViewController() })
            .disposed(by: rx.disposeBag)
        return viewController.viewModel.outputs.OTPResult
    }

    func success() {
        let viewController = PinChangeSuccessModuleBuilder(container: container).viewController()
        root.pushViewController(viewController)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.popToRootViewController() })
            .disposed(by: rx.disposeBag)
    }
}

extension ForgotPinCoordinator {
    func removeSecondLastViewController() {
        let count = root.viewControllers.count
        root.viewControllers.remove(at: count - 2)
    }

    func popToRootViewController() {
        let count = root.viewControllers.count
        let viewControllers = Array(root.viewControllers[0..<(count - 4)])
        root.setViewControllers(viewControllers, animated: true)
    }
}
