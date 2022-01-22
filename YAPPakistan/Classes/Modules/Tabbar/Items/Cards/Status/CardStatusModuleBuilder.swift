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
        case .ordering: return ("Ordering", "Building", "Shipping")
        case .ordered: return ("Ordered", "Building", "Shipping")
        case .booked: return ("Ordered", "Building", "Shipping")
        case .shipping: return ("Ordered", "Built", "Shipping")
        case .shipped: return ("Ordered", "Built", "Shipped")
        }
    }

    var action: (title: String, completedSteps: Int) {
        switch self {
        case .ordering: return ("Set PIN", 0) // ("Complete verification", 0)
        case .ordered: return ("Set PIN", 1)
        case .booked: return ("Set PIN", 3)
        case .shipping: return ("Set PIN", 4)
        case .shipped: return ("Set PIN", 5)
        }
    }
}