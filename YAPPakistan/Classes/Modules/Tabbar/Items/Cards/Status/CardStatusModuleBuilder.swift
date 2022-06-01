//
//  CardStatusModuleBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 16/11/2021.
//

import Foundation

struct CardStatusModuleBuilder {
    var container: UserSessionContainer
    var status: DeliveryStatus

    typealias Strings = CardStatusViewModel.LocalizedStrings
    func viewController() -> CardStatusViewController {
        let strings = Strings(title: "Primary card",
                               subTitle: "Primary card",
                               message: status.message,
                               status: status.status,
                               action: status.action.title)
        let viewModel = CardStatusViewModel(strings, completedSteps: status.action.completedSteps)
        let viewController = CardStatusViewController(themeService: container.themeService, viewModel: viewModel)
        return viewController
    }
}

fileprivate extension DeliveryStatus {
    var status: (order: String, build: String, ship: String) {
        switch self {
        case .ordered: return ("Ordered", "Shipped", "Delivered")
        case .shipped: return ("Ordered", "Shipped", "Delivered")
        case .delivered: return ("Ordered", "Shipped", "Delivered")
        case .failed: return ("Ordered", "Shipped", "Delivered")
        }
    }

    var action: (title: String, completedSteps: Int) {
        switch self {
        case .ordered: return ("Activate Card", 2)
        case .shipped: return ("Activate Card", 4)
        case .delivered: return ("Activate Card", 5)
        case .failed: return ("Activate Card", 0)
        }
    }
}
