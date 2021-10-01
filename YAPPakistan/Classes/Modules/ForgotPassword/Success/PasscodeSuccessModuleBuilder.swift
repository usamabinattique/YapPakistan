//
//  PasscodeSuccessModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/09/2021.
//

import Foundation

struct PasscodeSuccessModuleBuilder {
    let container: ForgotPasswordContainer

    func viewController() -> PasscodeSuccessViewController {
        let strings = PasscodeSuccessViewStrings(
            heading: "screen_passcode_success_display_text_heading".localized,
            subHeading: "screen_passcode_success_display_text_sub_heading".localized,
            action: "common_button_Done".localized
        )

        let viewModel = PasscodeSuccessViewModel(passcodeSuccessViewStrings: strings)

        return PasscodeSuccessViewController(themeService: container.themeService, viewModel: viewModel)
    }
}
