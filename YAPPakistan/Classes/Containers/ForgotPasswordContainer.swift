//
//  ForgotPasswordContainer.swift
//  YAPPakistan
//
//  Created by Sarmad on 01/10/2021.
//

import Foundation
import RxTheme
import YAPCore

public final class ForgotPasswordContainer {
    let parent: YAPPakistanMainContainer

    init(parent: YAPPakistanMainContainer) {
        self.parent = parent
    }

    // MARK: Properties
    var mainContainer: YAPPakistanMainContainer { parent }
    var themeService: ThemeService<AppTheme> { mainContainer.themeService }
    var credentialsStore: CredentialsStoreType { mainContainer.credentialsStore }

    // MARK: Repositry
    func makeOTPRepository() -> OTPRepositoryType { mainContainer.makeOTPRepository() }

    func makePINRepository() -> PINRepositoryType {
        PINRepository(customerService: mainContainer.makeCustomersService())
    }

    // MARK: Coordinator
    func makeForgotPasscodeCoordinator(root: UINavigationController) -> ForgotPasscodeCoordinator  {
        return ForgotPasscodeCoordinator(root: root, container: self)
    }

    // MARK: Controllers

    func makeForgotOTPViewController () -> VerifyMobileOTPViewController {
        return ForgotOTPModuleBuilder(container: self).viewController()
    }

    func makePasscodeViewController(token: String) -> PasscodeViewController {
        return CreateNewPasscodeBuilder(container: self, token: token).viewController()
    }

}
