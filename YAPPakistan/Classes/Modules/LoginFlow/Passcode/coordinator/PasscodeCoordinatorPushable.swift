//
//  PasscodeCoordinatorPushable.swift
//  Alamofire
//
//  Created by Sarmad on 20/09/2021.
//

import Foundation
import RxSwift
import YAPCore
import UIKit

class PasscodeCoordinatorPushable: Coordinator<PasscodeVerificationResult>, PasscodeCoordinatorType {
    var container: YAPPakistanMainContainer!
    var root: UINavigationController!
    var isUserBlocked:Bool

    var result = PublishSubject<PasscodeVerificationResult>()

    private var sessionContainer: UserSessionContainer!

    init(container: YAPPakistanMainContainer,
         root: UINavigationController,
         isUserBlocked: Bool) {
        self.root = root
        self.container = container
        self.isUserBlocked = isUserBlocked
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<PasscodeVerificationResult> {
        let viewController = container.makeVerifyPasscodeViewController(isUserBlocked: isUserBlocked) { session, accountProvider in
            self.sessionContainer = UserSessionContainer(parent: self.container, session: session)
            accountProvider = self.sessionContainer.accountProvider
        }

        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = false
        root.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.subscribe(onNext: { [weak self] in
            self?.root.popViewController(animated: true)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.result
            .filter { $0.isSuccess?.optRequired ?? true }
            .subscribe(onNext: { [weak self] _ in
                self?.optVerification()
            }).disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.loginResult
            .subscribe(onNext: { result in
                switch result {
                case .waiting:
                    self.waitingList()
                case .allowed:
                    self.reachedQueueTop()
                case .dashboard:
                    self.dashboard()
                case .cancel:
                    self.root.popViewController()
                default:
                    // FIXME: Handle other cases
                    break
                }
            }).disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.forgot.withUnretained(self)
            .subscribe(onNext: { $0.0.forgotOTPVerification() })
            .disposed(by: rx.disposeBag)

        return result
    }

    func optVerification() {

        coordinate(to: LoginOTPCoordinator(root: root, container: container))
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .cancel:
                    self?.root.popViewController(animated: true)
                    self?.result.onNext(.cancel)
                    self?.result.onCompleted()
                case .logout:
                    self?.result.onNext(.logout)
                    self?.result.onCompleted()
                default: break
                }
            }).disposed(by: rx.disposeBag)
    }

    func waitingList() {
        let window = root.view.window ?? UIWindow()
        let coordinator = WaitingListRankCoordinator(container: sessionContainer, window: window)

        coordinate(to: coordinator).subscribe(onNext: { _ in
            print("Moved to on verify passcode")
        }).disposed(by: rx.disposeBag)
    }

    func reachedQueueTop() {
        let window = root.view.window ?? UIWindow()
        let coordinator = ReachedQueueTopCoordinator(container: sessionContainer, window: window)

        coordinate(to: coordinator).subscribe(onNext: { _ in
            self.result.onNext(.logout)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    }

    func dashboard() {
        let window = root.view.window ?? UIWindow()
        let coordinator = LiteDashboardCoodinator(container: sessionContainer, window: window)

        coordinate(to: coordinator).subscribe(onNext: { result in
            self.result.onNext(.logout)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    }
}
