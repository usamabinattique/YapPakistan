//
//  LoginOTPCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 21/09/2021.
//

import Foundation
import RxSwift
import YAPCore
import UIKit

public enum LoginOTPVerificationResult: Hashable {
    case waiting
    case allowed
    case onboarding
    case blocked
    case dashboard
    case cancel
    case logout
}

protocol LoginOTPCoordinatorType: Coordinator<LoginOTPVerificationResult> {

    var root: UINavigationController! { get }
    var container: YAPPakistanMainContainer! { get }
    var result: PublishSubject<LoginOTPVerificationResult> { get }

}

class LoginOTPCoordinator: Coordinator<LoginOTPVerificationResult>, LoginOTPCoordinatorType {

    var root: UINavigationController!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<LoginOTPVerificationResult>()

    private var sessionContainer: UserSessionContainer!

    init(root: UINavigationController,
         container: YAPPakistanMainContainer
    ){
        self.root = root
        self.container = container
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<LoginOTPVerificationResult> {

        let otpRepository = container.makeOTPRepository()
        let sessionProvider = container.makeSessionProvider()
        let username = container.credentialsStore.getUsername() ?? ""
        let passcode = container.credentialsStore.getPasscode(username: username) ?? ""

        let viewModel = container
            .makeLoginOTPVerificationViewModel(
                otpRepository: otpRepository,
                sessionProvider: sessionProvider,
                userName: username,
                passcode: passcode ) { session, accountProvider, demographicsRepository in

                self.sessionContainer = UserSessionContainer(parent: self.container, session: session)
                accountProvider = self.sessionContainer.accountProvider
                demographicsRepository = self.sessionContainer.makeDemographicsRepository()
            }

        let viewController = container.makeVerifyMobileOTPViewController(viewModel: viewModel)

        root.pushViewController(viewController)

        viewModel.back.subscribe(onNext: { [weak self] in
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
            
            self?.root.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)

        viewModel.outputs.loginResult.subscribe(onNext: { result in
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

    func waitingList() {
        let window = root.view.window ?? UIWindow()
        let coordinator = WaitingListRankCoordinator(container: sessionContainer, window: window)

        coordinate(to: coordinator).subscribe(onNext: { _ in
            print("Moved to on login OTP")
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
        container.configuration.eventCallback?(.loggedIn)
        
        coordinate(to: coordinator).subscribe(onNext: { _ in
            self.result.onNext(.logout)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    }
}
