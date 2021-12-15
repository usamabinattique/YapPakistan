//
//  CardOptionsModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 08/12/2021.
//

import Foundation
struct CardOptionsModuleBuilder {
    func viewController() -> AlertController {
        let actions: [AlertViewModel.ActionViewModel] = [
            .init(title: "Name your card", style: .default),
            .init(title: "Change PIN", style: .default),
            .init(title: "Forgot PIN", style: .default),
            .init(title: "View statement", style: .default),
            .init(title: "Report lost or stolen", style: .default),
            .init(title: "Cancel", style: .cancel)
        ]
        return AlertBuilder(tiele: nil, message: nil, style: .actionSheet, actions: actions )
            .viewController()
    }
}
