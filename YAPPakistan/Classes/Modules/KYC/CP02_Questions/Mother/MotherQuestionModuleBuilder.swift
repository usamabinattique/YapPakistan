//
//  MotherQuestionModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation
struct MotherQuestionModuleBuilder {
    let container: KYCFeatureContainer

    func viewController() -> KYCQuestionsViewController {
        let strings = KYCStrings(title: "screen_kyc_questions_mothers_name".localized,
                                 subHeading: "screen_kyc_questions_reason".localized,
                                 next: "common_button_next".localized )
        let viewModel = MotherMaidenNamesViewModel(accountProvider: container.accountProvider,
                                                   kycRepository: container.makeKYCRepository(),
                                                   strings: strings)
        return KYCQuestionsViewController(themeService: container.themeService, viewModel: viewModel)
    }
}
