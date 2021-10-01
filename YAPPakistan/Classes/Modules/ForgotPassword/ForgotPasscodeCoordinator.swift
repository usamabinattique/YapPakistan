//
//  ForgotOTPCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 28/09/2021.
//

import Foundation
import RxSwift
import YAPCore
import UIKit

protocol ForgotPasscodeCoordinatorType: Coordinator<ResultType<Void>> {
    var root: UINavigationController! { get }
    var container: ForgotPasswordContainer! { get }
    var result: PublishSubject<ResultType<Void>> { get }
}

class ForgotPasscodeCoordinator: Coordinator<ResultType<Void>>, ForgotPasscodeCoordinatorType {

    var root: UINavigationController!
    var container: ForgotPasswordContainer!
    var result = PublishSubject<ResultType<Void>>()

    private var sessionContainer: UserSessionContainer!

    init(root: UINavigationController,
         container: ForgotPasswordContainer
    ) {
        self.root = root
        self.container = container
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        let viewController = container.makeForgotOTPViewController()
        let viewModel = viewController.viewModel as? ForgotOTPVerificationViewModel

        root.pushViewController(viewController)

        viewModel?.back.subscribe(onNext: { [weak self] in
            self?.result.onNext(.cancel)
            self?.result.onCompleted()

            self?.root.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)

        viewModel?.OTPResult.subscribe(onNext: { result in
            self.newPassword(token: result)
        }).disposed(by: rx.disposeBag)

        return result
    }

    func newPassword(token: String) {
        let passcodeViewController = container.makePasscodeViewController(token: token)

        passcodeViewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: {
                let count = $0.0.root.viewControllers.count
                $0.0.root.viewControllers.remove(at: count - 2)
                $0.0.root.popViewController(animated: true)
                $0.0.result.onNext(.cancel)
                $0.0.result.onCompleted()
            })
            .disposed(by: rx.disposeBag)

        passcodeViewController.viewModel.outputs.result.withUnretained(self)
            .subscribe(onNext: { [weak self]_ in self?.successScreen() })
            .disposed(by: rx.disposeBag)

        self.root.pushViewController(passcodeViewController)
    }

    func successScreen() {
        print("Password changed successfully")
    }
}
