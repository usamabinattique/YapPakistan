//
//  UserSessionContainer.swift
//  YAPPakistan
//
//  Created by Tayyab on 14/09/2021.
//

import Foundation

public final class UserSessionContainer {
    let parent: YAPPakistanMainContainer
    let session: Session
    let accountProvider: AccountProvider

    init(parent: YAPPakistanMainContainer, session: Session) {
        self.parent = parent
        self.session = session

        let authService = AuthenticationService(authorizationProvider: session)
        let customersService = parent.makeCustomersService(authorizationProvider: session)
        let repository = AccountRepository(authenticationService: authService, customerService: customersService)

        self.accountProvider = AccountProvider(repository: repository)
    }

    func makeOnBoardingRepository() -> OnBoardingRepository {
        let customersService = parent.makeCustomersService(authorizationProvider: session)
        let messagesService = parent.makeMessagesService(authorizationProvider: session)
        let onBoardingRepository = OnBoardingRepository(customersService: customersService, messagesService: messagesService)

        return onBoardingRepository
    }

    func makeWaitingListController() -> WaitingListRankViewController {
        let onBoardingRepository = makeOnBoardingRepository()
        let viewModel = WaitingListRankViewModel(accountProvider: accountProvider, referralManager: parent.referralManager, onBoardingRepository: onBoardingRepository)

        return WaitingListRankViewController(themeService: parent.themeService, viewModel: viewModel)
    }
}
