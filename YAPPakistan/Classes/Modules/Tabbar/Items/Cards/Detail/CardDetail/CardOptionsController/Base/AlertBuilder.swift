//
//  AlertViewBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 08/12/2021.
//

import Foundation
struct AlertBuilder {
    var tiele: String? = nil
    var message: String? = nil
    var style: UIAlertController.Style = .actionSheet
    var actions: [AlertViewModel.ActionViewModel] = []

    func viewController() -> AlertController {
        let viewModel = AlertViewModel(title: tiele, message: message, style: style, actions: actions)
        let alert = AlertController(viewModel: viewModel)
        return alert
    }
}
