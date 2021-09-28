//
//  PasscodeCoordinatorReplaceable.swift
//  YAPPakistan
//
//  Created by Sarmad on 23/09/2021.
//

import Foundation
import RxSwift
import YAPCore
import UIKit

class PasscodeCoordinatorReplaceable: Coordinator<PasscodeVerificationResult>, PasscodeCoordinatorType {
    var window: UIWindow!
    var root: UINavigationController!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<PasscodeVerificationResult>()

    private var sessionContainer: UserSessionContainer!

    init(window: UIWindow,
         xsrfToken: String,
         container: YAPPakistanMainContainer
    ){
        self.window = window
        self.container = container
        self.container.xsrfToken = xsrfToken
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<PasscodeVerificationResult> {

        let viewModel = container.makeVerifyPasscodeViewModel { session, accountProvider in
            self.sessionContainer = UserSessionContainer(parent: self.container, session: session)
            accountProvider = self.sessionContainer.accountProvider
        }
        let loginViewController = container.makeVerifyPasscodeViewController(viewModel: viewModel)

        root = UINavigationController(rootViewController: loginViewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = false

        self.window.rootViewController = self.root

        viewModel.outputs.back.subscribe(onNext: { [unowned self] in

            self.coordinate(to: LoginCoordinatorReplaceable(window: window,
                                                            xsrfToken: container.xsrfToken,
                                                            container: container))
                .subscribe(onNext: { result in
                    self.result.onNext(.logout)
                    self.result.onCompleted()
                })
                .disposed(by: self.rx.disposeBag)

            self.result.onNext(.cancel)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        viewModel.outputs.result
            .filter({ $0.isSuccess?.optRequired ?? true })
            .subscribe(onNext: { [weak self] _ in self?.optVerification() })
            .disposed(by: rx.disposeBag)

        viewModel.outputs.loginResult
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

        return result
    }

    func optVerification() {

        coordinate(to: LoginOTPCoordinator(root: root, xsrfToken: container.xsrfToken, container: container))
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

        coordinate(to: coordinator).subscribe(onNext: { _ in
            self.result.onNext(.logout)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    }
}
