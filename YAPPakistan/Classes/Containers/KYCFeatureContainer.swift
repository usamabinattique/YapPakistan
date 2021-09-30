//
//  KYCFeatureContainer.swift
//  YAPPakistan
//
//  Created by Tayyab on 30/09/2021.
//

import Foundation
import RxTheme

public final class KYCFeatureContainer {
    let parent: UserSessionContainer

    init(parent: UserSessionContainer) {
        self.parent = parent
    }

    // MARK: Properties

    var mainContainer: YAPPakistanMainContainer {
        return parent.parent
    }

    var themeService: ThemeService<AppTheme> {
        return parent.themeService
    }

    var session: Session {
        return parent.session
    }

    var accountProvider: AccountProvider {
        return parent.accountProvider
    }

    // MARK: Repositories

    func makeKYCRepository() -> KYCRepository {
        let customersService = parent.makeCustomersService()
        let kycRepository = KYCRepository(customersService: customersService)

        return kycRepository
    }

    // MARK: Controllers

    func makeKYCProgressViewController(navigationController: UINavigationController) -> KYCProgressViewController {
        let viewModel = KYCProgressViewModel()
        let viewController = KYCProgressViewController(themeService: themeService,
                                                       viewModel: viewModel,
                                                       withChildNavigation: navigationController)

        return viewController
    }

    func makeKYCHomeViewController(initiatedFromDashboard: Bool) -> KYCHomeViewController {
        let kycRepository = makeKYCRepository()
        let viewModel = KYCHomeViewModel(accountProvider: accountProvider,
                                         kycRepository: kycRepository,
                                         initiatedFromDashboard: initiatedFromDashboard)
        let viewController = KYCHomeViewController(themeService: themeService, viewModel: viewModel)

        return viewController
    }
}
