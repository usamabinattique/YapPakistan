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
    
    var root: UINavigationController!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<LoginOPTVerificationResult>()

    init(root: UINavigationController,
         xsrfToken: String,
         container: YAPPakistanMainContainer
    ){
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
        let sessionCreator = UserSessionContainer(parent: container, session: Session(guestToken: "", sessionToken: ""))
        
        let otpRepository = OTPRepository(messageService: MessagesService(apiConfig: apiConfig, authorizationProvider: authService),
                                          customerService: CustomersService(apiConfig: apiConfig, authorizationProvider: authService))
        let viewModel = LoginOTPVerificationViewModel(action: .deviceVerification,
                                                 heading: nil,
                                                 subheading: NSAttributedString(string: otpMessage),
                                                 image: appLogo,
                                                 repository: otpRepository,
                                                 username: "00923331699972", //credentials.username,
                                                 passcode: "1212", //credentials.passcode,
                                                 sessionCreator: sessionCreator as! SessionProviderType)
        let viewController =  VerifyMobileOTPViewController(themeService: container.themeService, viewModel: viewModel)
        
        root.pushViewController(viewController)

        return result
    }
    
}
