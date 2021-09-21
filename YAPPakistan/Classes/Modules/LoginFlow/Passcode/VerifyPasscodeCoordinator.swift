//
//  VerifyPasscodeCoordinator.swift
//  Alamofire
//
//  Created by Sarmad on 20/09/2021.
//

import Foundation
import RxSwift
import YAPCore
import UIKit

enum PasscodeVerificationResult {
    case onboarding
    case dashboard(session: Session)
    case cancel
}

protocol PasscodeCoordinatorType: Coordinator<PasscodeVerificationResult> {

    var root: UINavigationController! { get }
    var container:YAPPakistanMainContainer! { get }
    var result: PublishSubject<PasscodeVerificationResult> { get }

}

class PasscodeCoordinator: Coordinator<PasscodeVerificationResult>, PasscodeCoordinatorType {
    
    var root: UINavigationController!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<PasscodeVerificationResult>()

    init(root: UINavigationController,
         xsrfToken: String,
         container: YAPPakistanMainContainer
    ){
        self.root = root
        self.container = container
        self.container.xsrfToken = xsrfToken
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<PasscodeVerificationResult> {
        
        let viewModel = container.makeVerifyPasscodeViewModel(repository: container.makeLoginRepository())
        let loginViewController = container.makePINViewController(viewModel: viewModel)

        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = false
        root.pushViewController(loginViewController, animated: true)
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] in
            self?.root.popViewController(animated: true)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.result.subscribe(onNext: { [weak self] _ in
            self?.optVerification()
        }).disposed(by: rx.disposeBag)

        return result
    }
    
    func optVerification() {
        
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
        
        viewController.rx.viewDidAppear.withUnretained(self).subscribe(onNext: {
            $0.0.result.onNext(.cancel)
            $0.0.result.onCompleted()
            $0.0.root.viewControllers.remove(at: $0.0.root.viewControllers.count - 2)
        }).disposed(by: rx.disposeBag)
        
        root.pushViewController(viewController)
    }
    
}
