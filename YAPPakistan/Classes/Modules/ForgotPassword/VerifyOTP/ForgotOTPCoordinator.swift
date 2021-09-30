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

public enum ForgotOTPVerificationResult {
    case cancel
}

protocol ForgotOTPCoordinatorType: Coordinator<ForgotOTPVerificationResult> {

    var root: UINavigationController! { get }
    var container: YAPPakistanMainContainer! { get }
    var result: PublishSubject<ForgotOTPVerificationResult> { get }

}

class ForgotOTPCoordinator: Coordinator<ForgotOTPVerificationResult>, ForgotOTPCoordinatorType {
    let xsrfToken: String
    var root: UINavigationController!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<ForgotOTPVerificationResult>()

    private var sessionContainer: UserSessionContainer!

    init(root: UINavigationController,
         xsrfToken: String,
         container: YAPPakistanMainContainer
    ){
        self.xsrfToken = xsrfToken
        self.root = root
        self.container = container
        self.container.xsrfToken = xsrfToken
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ForgotOTPVerificationResult> {

        /*let viewModel = container
            .makeForgotOTPVerificationViewModel() */

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
        let pinrepo = PINRepository(customerService: container.makeCustomersService(xsrfToken: container.xsrfToken))
        let username = container.credentialsStore.getUsername() ?? ""
        let viewModel = CreateNewPasscodeViewModel(repository: pinrepo, credentialsManager: container.credentialsStore, username: username, token: token)
        let viewController = PasscodeViewController(themeService: container.themeService, viewModel: viewModel)

        viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: {
                let count = $0.0.root.viewControllers.count
                $0.0.root.viewControllers.remove(at: count - 2)
                $0.0.root.popViewController(animated: true)
                $0.0.result.onNext(.cancel)
                $0.0.result.onCompleted()
            })
            .disposed(by: rx.disposeBag)

        viewModel.outputs.result.withUnretained(self)
            .subscribe(onNext: { [weak self]_ in self?.successScreen() })
            .disposed(by: rx.disposeBag)

        self.root.pushViewController(viewController)
    }

    func successScreen() {
        let viewModel = PasscodeSuccessViewModel()
        let viewController = PasscodeSuccessViewController(themeService: container.themeService, viewModel: viewModel)

        viewModel.outputs.action.withUnretained(self)
            .subscribe(onNext: {
                let count = $0.0.root.viewControllers.count
                $0.0.root.viewControllers.remove(at: count - 2)
                $0.0.root.viewControllers.remove(at: count - 2)
                $0.0.root.popViewController(animated: true)
                $0.0.result.onNext(.cancel)
                $0.0.result.onCompleted()
            })
            .disposed(by: rx.disposeBag)
        self.root.pushViewController(viewController)
    }
}
