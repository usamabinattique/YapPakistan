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
            print(result)
        }).disposed(by: rx.disposeBag)

        return result
    }

    func newPassword(token:String) {

    }
}
