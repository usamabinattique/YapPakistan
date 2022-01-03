//
//  VerifyPinChangeModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 12/12/2021.
//

struct VerifyPinChangeModuleBuilder {
    let container: UserSessionContainer

    func viewController() -> VerifyMobileOTPViewController {
        let otpRepository = container.makeOTPRepository()

        let heading: String = "Verify your PIN change"
        let mobileNo: String = container.parent.credentialsStore.getUsername() ?? ""
        let otpMessage: String = "screen_device_registration_otp_display_givn_text_message".localized
        let subHeading = String(format: otpMessage, mobileNo.toFormatedPhoneNumber)

        let viewModel = VerifyPinChangeViewModel(action: OTPAction.forgotPassword,
                                                 heading: heading,
                                                 subheading: subHeading,
                                                 image: nil,
                                                 repository: otpRepository)

        return VerifyMobileOTPViewController(themeService: container.themeService, viewModel: viewModel)
    }
}

