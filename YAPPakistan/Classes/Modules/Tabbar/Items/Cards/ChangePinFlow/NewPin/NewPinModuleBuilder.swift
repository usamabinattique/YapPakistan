//
//  NewPinModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/12/2021.
//

import Foundation

struct NewPinModuleBuilder {
    let container: UserSessionContainer

    func viewController() -> NewPinViewController {
        let themeService = container.themeService

        let strings = NewPinViewStrings(heading: "Enter your new 4-digit PIN code",
                                            agrement: "",
                                            terms: "",
                                            next: "common_button_next".localized)
        let viewModel = NewPinViewModel(strings: strings)
        return NewPinViewController(themeService: themeService, viewModel: viewModel)
    }
}
