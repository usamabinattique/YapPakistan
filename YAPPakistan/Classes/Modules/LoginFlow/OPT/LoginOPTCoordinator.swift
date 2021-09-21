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

enum LoginOPTVerificationResult {
    case onboarding
    case dashboard(session: Session)
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
                                                 sessionCreator: sessionProvider)
        let viewController =  VerifyMobileOTPViewController(themeService: container.themeService, viewModel: viewModel)
        
        viewModel.back.subscribe(onNext: { [weak self] in
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
            
            let count = self?.root.viewControllers.count ?? 2
            self?.root.viewControllers.remove(at: count - 2)
            
            self?.root.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        
        root.pushViewController(viewController)

        return result
    }
    
}
