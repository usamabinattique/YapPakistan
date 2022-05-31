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
    var isUserBlocked: Bool

    private var sessionContainer: UserSessionContainer!
    
    fileprivate lazy var biometricManager = container.makeBiometricsManager()
    fileprivate lazy var notifManager = NotificationManager()
    fileprivate lazy var username: String! = container.credentialsStore.getUsername() ?? ""

    fileprivate var isNeededBiometryPermissionPrompt: Bool {
        return !biometricManager.isBiometryPermissionPrompt(for: username) && biometricManager.isBiometrySupported
    }

    init(window: UIWindow,
         container: YAPPakistanMainContainer,
         isUserBlocked: Bool
    ){
        self.window = window
        self.container = container
        self.isUserBlocked = isUserBlocked
    }

    deinit {
        print("PasscodeCoordinatorReplaceable")
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<PasscodeVerificationResult> {
        let viewController = container.makeVerifyPasscodeViewController(isUserBlocked: isUserBlocked) { session, accountProvider in
            self.sessionContainer = UserSessionContainer(parent: self.container, session: session)
            accountProvider = self.sessionContainer.accountProvider
        }

        root = UINavigationController(rootViewController: viewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = false

        self.window.rootViewController = self.root

        viewController.viewModel.outputs.back.subscribe(onNext: { [unowned self] in
            self.result.onNext(.cancel)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.result
            .filter({ $0.isSuccess?.optRequired ?? true })
            .subscribe(onNext: { [weak self] _ in self?.optVerification() })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.loginResult
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { `self`, result in
                
                self.bioMetricPermission(result: result)
                
            }).disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.forgot.withUnretained(self)
            .subscribe(onNext: { _ in
                self.forgotOTPVerification()
            })
            .disposed(by: rx.disposeBag)

        return result
    }
    
    func handleResult(result: PasscodeVerificationResult) {
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
        let coordinator = TabbarCoodinator(container: sessionContainer, window: window)

        coordinate(to: coordinator).subscribe(onNext: { _ in
            self.result.onNext(.logout)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    }
    
    func forgotOTPVerification() {
        
        let forgotPasswordContainer = ForgotPasswordContainer(parent: self.container)

        coordinate(to: forgotPasswordContainer.makeForgotPasscodeCoordinator(root: root) )
            .subscribe(onNext: { [weak self] result in
                self?.result.onNext(.cancel)
                self?.result.onCompleted()
            })
            .disposed(by: rx.disposeBag)
    }
}

extension PasscodeCoordinatorReplaceable {
    
    fileprivate func bioMetricPermission(result: PasscodeVerificationResult) {
        guard isNeededBiometryPermissionPrompt else {
            notificationPermission(result: result)
            return
        }

        let viewController = container.makeBiometricPermissionViewController()
        viewController.modalPresentationStyle = .fullScreen

        self.root.present(viewController, animated: true, completion: nil)

        viewController.viewModel.outputs.thanks.merge(with: viewController.viewModel.outputs.success)
            .subscribe(onNext: { [weak self] _ in
                self?.root.dismiss(animated: true) { [weak self] in
                    self?.notificationPermission(result: result)
                }
            })
            .disposed(by: rx.disposeBag)
    }

    fileprivate func notificationPermission(result: PasscodeVerificationResult) {
        guard !self.notifManager.isNotificationPermissionPrompt else {
            self.handleResult(result: result)
            return
        }

        let viewController = container.makeNotificationPermissionViewController()
        viewController.modalPresentationStyle = .fullScreen

        self.root.present(viewController, animated: true, completion: nil)

        viewController.viewModel.outputs.thanks.merge(with: viewController.viewModel.outputs.success)
            .subscribe(onNext: { [weak self] _ in
                self?.root.dismiss(animated: true, completion: {
                    self?.handleResult(result: result)
                })
            })
            .disposed(by: rx.disposeBag)
    }
}
