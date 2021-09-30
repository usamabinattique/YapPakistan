//
//  ForgotOTPModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/09/2021.
//

import Foundation

struct ForgotOTPModuleBuilder {
    let container: YAPPakistanMainContainer

    func viewController() -> VerifyMobileOTPViewController {
        let messageService = container.makeMessagesService(xsrfToken: container.xsrfToken)
        let customerService = container.makeCustomersService(xsrfToken: container.xsrfToken)
        let otpRepository = container.makeOTPRepository(messageService: messageService,
                                                        customerService: customerService)
        let sessionProvider = container.makeSessionProvider(xsrfToken: container.xsrfToken)

        let logo: UIImage? = UIImage(named: "icon_app_logo", in: .yapPakistan)
        let heading: String = "screen_device_registration_otp_display_header_message".localized
        let mobileNo: String = container.credentialsStore.getUsername() ?? ""
        let otpMessage: String = "screen_device_registration_otp_display_givn_text_message".localized
        let subHeading = String(format: otpMessage, mobileNo.toFormatedPhoneNumber)
        let passcode: String = container.credentialsStore.getPasscode(username: mobileNo) ?? ""

        let viewModel = ForgotOTPVerificationViewModel(action: OTPAction.forgotPassword,
                                                       heading: heading,
                                                       subheading: subHeading,
                                                       image: logo,
                                                       repository: otpRepository,
                                                       mobileNo: mobileNo,
                                                       username: mobileNo,
                                                       passcode: passcode,
                                                       sessionCreator: sessionProvider)

        return VerifyMobileOTPViewController(themeService: container.themeService, viewModel: viewModel)
    }
}
