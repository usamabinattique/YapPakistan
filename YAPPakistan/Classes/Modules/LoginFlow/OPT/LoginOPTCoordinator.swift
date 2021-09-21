//
//  LoginOPTCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 21/09/2021.
//

import Foundation
import RxSwift
import YAPCore
import UIKit

public enum LoginOPTVerificationResult {
    case waiting
    case allowed
    case onboarding
    case blocked
    case dashboard
    case cancel
}

protocol LoginOPTCoordinatorType: Coordinator<LoginOPTVerificationResult> {

    var root: UINavigationController! { get }
    var container:YAPPakistanMainContainer! { get }
    var result: PublishSubject<LoginOPTVerificationResult> { get }

}

class LoginOPTCoordinator: Coordinator<LoginOPTVerificationResult>, LoginOPTCoordinatorType {
    let xsrfToken: String
    var root: UINavigationController!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<LoginOPTVerificationResult>()

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

    override func start(with option: DeepLinkOptionType?) -> Observable<LoginOPTVerificationResult> {
        
        let otpMessage =  "screen_device_registration_otp_display_text_message".localized
        let appLogo = UIImage(named: "icon_app_logo")
        let authService = container.makeAuthorizationProvider(xsrfToken: container.xsrfToken)
        let apiConfig = container.makeAPIConfiguration()
        //let credentials = container.credentialsStore
        let sessionProvider = SessionProvider(xsrfToken: xsrfToken)
        
        let userName = container.credentialsStore.getUsername() ?? ""
        let passcode = container.credentialsStore.getPasscode(username: userName) ?? ""
        
        let otpRepository = OTPRepository(messageService: MessagesService(apiConfig: apiConfig, authorizationProvider: authService),
                                          customerService: CustomersService(apiConfig: apiConfig, authorizationProvider: authService))
        let viewModel = LoginOTPVerificationViewModel(action: .deviceVerification,
                                                 heading: nil,
                                                 subheading: NSAttributedString(string: otpMessage),
                                                 image: appLogo,
                                                 repository: otpRepository,
                                                 username: userName,
                                                 passcode: passcode,
                                                 sessionCreator: sessionProvider,
                                                 onLogin: { session, accountProvider in
                                                    self.sessionContainer = UserSessionContainer(parent: self.container, session: session)
                                                    accountProvider = self.sessionContainer.accountProvider
                                                })
        let viewController =  VerifyMobileOTPViewController(themeService: container.themeService, viewModel: viewModel)

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

        root.pushViewController(viewController)

        return result
    }

    func waitingList() {
        let viewController = container.makeWaitingListController(session: sessionContainer.session)
        root.viewControllers = [viewController]
    }

    func reachedQueueTop() {
        let window = root.view.window ?? UIWindow()
        let coordinator = ReachedQueueTopCoordinator(container: sessionContainer, window: window)

        coordinate(to: coordinator).subscribe(onNext: { _ in
            print("Moved to reached top of the queue")
        }).disposed(by: rx.disposeBag)
    }

    func dashboard() {
        let window = root.view.window ?? UIWindow()
        let coordinator = LiteDashboardCoodinator(container: sessionContainer, window: window)

        coordinate(to: coordinator).subscribe(onNext: { _ in
            print("Moved to lite dashboard")
        }).disposed(by: rx.disposeBag)
    }
}
