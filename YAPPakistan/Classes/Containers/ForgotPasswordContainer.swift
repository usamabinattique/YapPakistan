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
    var themeService: ThemeService<AppTheme> { parent.themeService }
    var credentialsStore:CredentialsStoreType { parent.credentialsStore }

    // MARK: Repositry
    func makeOTPRepository() -> OTPRepositoryType  { mainContainer.makeOTPRepository() }

    // MARK: Coordinator
    func makeForgotPasscodeCoordinator(root: UINavigationController) -> ForgotPasscodeCoordinator  {
        return ForgotPasscodeCoordinator(root: root, container: self)
    }

    // MARK: Controllers

    func makeForgotOTPViewController () -> VerifyMobileOTPViewController {
        return ForgotOTPModuleBuilder(container: self).viewController()
    }

}

