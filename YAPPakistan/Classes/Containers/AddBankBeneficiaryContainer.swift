//
//  AddBankBeneficiaryContainer.swift
//  YAPPakistan
//
//  Created by Yasir on 21/03/2022.
//

import Foundation
import RxTheme
import RxSwift
import RxCocoa
import UIKit

public final class AddBankBeneficiaryContainer {
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
        return parent.makeKYCRepository()
    }
    
    func makeY2YRepository() -> Y2YRepository {
        return parent.makeY2YRepository()
    }
    
}

//MARK: AddBankBeneficiaryContainer
extension AddBankBeneficiaryContainer {
    func makeAddBeneficiaryContainerViewController(withViewModel viewModel: AddSendMoneyBeneficiaryViewModel, childNavigation: UINavigationController) ->  AddBeneficiaryContainerViewController {
        
        return AddBeneficiaryContainerViewController(themeService: parent.themeService, viewModel: viewModel, childNavigation: childNavigation)
    }
    
    func makeAddSendMoneyBeneficiaryViewController(withViewModel viewModel: AddSendMoneyBeneficiaryViewModel, childNavigation: UINavigationController) -> AddSendMoneyBeneficiaryViewController {
        return AddSendMoneyBeneficiaryViewController(themeService: parent.themeService, viewModel, childNavigation: childNavigation)
    }
    
    func makeVerifyMobileOTPViewController(withViewModel viewModel: VerifyMobileOTPViewModel) -> VerifyMobileOTPViewController {
        return VerifyMobileOTPViewController(themeService: parent.themeService, viewModel: viewModel)
    }
    
    func makeAddBeneficiaryBankListViewController(withViewModel viewModel: AddBeneficiaryBankListViewModel) -> AddBeneficiaryBankListViewController {
        return AddBeneficiaryBankListViewController(themeService: parent.themeService, viewModel: viewModel)
    }
    
    func makeBankListSearchViewController(withViewModel viewModel: BankListSearchViewModel) -> BankListSearchViewController {
        return BankListSearchViewController(themeService: parent.themeService, viewModel: viewModel)
    }
    
    func makeAddBeneficiaryBankDetailViewController(withViewModel viewModel: AddBeneficiaryBankDetailViewModel) -> AddBeneficiaryBankDetailViewController {
        return AddBeneficiaryBankDetailViewController(themeService: parent.themeService, viewModel: viewModel)
    }
    
    func makeAddBeneficiaryConfirmViewController(withViewModel viewModel: AddBeneficiaryConfirmViewModel) -> AddBeneficiaryConfirmViewController {
        return AddBeneficiaryConfirmViewController(themeService: parent.themeService, viewModel: viewModel)
    }
    
    func makeAddBeneficiaryBankListContainerNavigationController(rootViewController: UIViewController) -> AddBeneficiaryBankListContainerNavigationController {
        return AddBeneficiaryBankListContainerNavigationController(themeService: parent.themeService, rootViewController: rootViewController)
    }
}
