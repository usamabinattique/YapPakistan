//
//  CardNameModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation

struct CardNameModuleBuilder {
    let container: KYCFeatureContainer
    let paymentGatewayM: PaymentGatewayLocalModel
    func viewController() -> CardNameViewController {
        let kycRepository = container.makeKYCRepository()
        let accountProvider = container.accountProvider
        let themeService = container.themeService

        let viewModel = CardNameViewModel(kycRepository: kycRepository, accountProvider: accountProvider, paymentGatewayM: paymentGatewayM)

        return CardNameViewController(themeService: themeService, viewModel: viewModel)
    }
}
