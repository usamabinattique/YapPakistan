//
//  ForgotOTPModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/09/2021.
//

import Foundation

struct ForgotOTPModuleBuilder {
    let container: ForgotPasswordContainer

    func viewController() -> VerifyMobileOTPViewController {
        let otpRepository = container.makeOTPRepository()

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
                                                       passcode: passcode)

        return VerifyMobileOTPViewController(themeService: container.themeService, viewModel: viewModel)
    }
}
