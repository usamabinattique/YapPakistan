//
//  CityQuestionModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation

struct CityQuestionModuleBuilder {
    let container: KYCFeatureContainer
    let motherName: String
    func viewController() -> KYCQuestionsViewController {
        let strings = KYCStrings(title: "screen_kyc_questions_city_of_birth".localized,
                                 subHeading: "screen_kyc_questions_reason".localized,
                                 next: "common_button_next".localized )
        let viewModel = CityOfBirthNamesViewModel(accountProvider: container.accountProvider,
                                                  kycRepository: container.makeKYCRepository(),
                                                  strings: strings,
                                                  motherName: motherName)
        return KYCQuestionsViewController(themeService: container.themeService, viewModel: viewModel)
    }
}
