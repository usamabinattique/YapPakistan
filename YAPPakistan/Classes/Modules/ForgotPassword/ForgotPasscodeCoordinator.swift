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
    var container: YAPPakistanMainContainer! { get }
    var result: PublishSubject<ResultType<Void>> { get }
}

class ForgotPasscodeCoordinator: Coordinator<ResultType<Void>>, ForgotPasscodeCoordinatorType {

    var root: UINavigationController!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<ResultType<Void>>()

    private var sessionContainer: UserSessionContainer!

    init(root: UINavigationController,
         container: YAPPakistanMainContainer
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
            print(result)
        }).disposed(by: rx.disposeBag)

        return result
    }

    func newPassword(token: String) {

    }
}
