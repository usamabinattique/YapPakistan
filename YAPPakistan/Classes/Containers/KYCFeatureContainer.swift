//
//  KYCFeatureContainer.swift
//  YAPPakistan
//
//  Created by Tayyab on 30/09/2021.
//

import CardScanner
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
        return parent.makeKYCRepository()
    }

    // MARK: Coordinators

    func makeKYCReviewCoordinator(root: UINavigationController,
                                  identityDocument: IdentityDocument,
                                  cnicOCR: CNICOCR) -> KYCReviewCoordinator {
        return KYCReviewCoordinator(container: self, root: root,
                                    identityDocument: identityDocument, cnicOCR: cnicOCR)
    }

    func makeKYCQuestionsCoordinator(root: UINavigationController) -> KYCQuestionsCoordinator {
        KYCQuestionsCoordinator(root: root, container: self)
    }

    func makeSelfieCoordinator(root: UINavigationController) -> SelfieCoordinator {
        SelfieCoordinator(root: root, container: self)
    }

    func makeCardNameCoordinator(root: UINavigationController) -> CardNameCoordinator {
        CardNameCoordinator(root: root, container: self)
    }

    func makeAddressCoordinator(root: UINavigationController) -> AddressCoordinator {
        AddressCoordinator(root: root, container: self)
    }

    // MARK: Controllers

    func makeNavigationController(root: UIViewController? = nil) -> UINavigationController {
        return parent.parent.makeNavigationController(root: root)
    }

    func makeNavigationContainerViewController() -> NavigationContainerViewController {
        return parent.parent.makeNavigationContainerController()
    }

    func makeKYCProgressViewController(navigationController: UINavigationController) -> KYCProgressViewController {
        let viewModel = KYCProgressViewModel()
        let viewController = KYCProgressViewController(themeService: themeService,
                                                       viewModel: viewModel,
                                                       withChildNavigation: navigationController)
        return viewController
    }
    func makeKYCProgressViewController() -> KYCProgressViewController {
        let childNav: UINavigationController = makeNavigationController()
        childNav.setNavigationBarHidden(true, animated: false)
        return makeKYCProgressViewController(navigationController: childNav)
    }

    func makeKYCHomeViewController() -> KYCHomeViewController {
        let kycRepository = makeKYCRepository()
        let viewModel = KYCHomeViewModel(accountProvider: accountProvider,
                                         kycRepository: kycRepository)
        let viewController = KYCHomeViewController(themeService: themeService,
                                                   viewModel: viewModel)

        return viewController
    }

    func makeKYCInitialReviewViewController(cnicOCR: CNICOCR) -> KYCInitialReviewViewController {
        let viewModel = KYCInitialReviewViewModel(accountProvider: accountProvider,
                                                  kycRepository: makeKYCRepository(),
                                                  cnicOCR: cnicOCR)
        let viewController = KYCInitialReviewViewController(themeService: themeService,
                                                            viewModel: viewModel)

        return viewController
    }

    func makeKYCReviewDetailsViewController(identityDocument: IdentityDocument, cnicNumber: String, cnicInfo: CNICInfo) -> KYCReviewDetailsViewController {
        let viewModel = KYCReviewDetailsViewModel(accountProvider: accountProvider,
                                                  kycRepository: makeKYCRepository(),
                                                  identityDocument: identityDocument,
                                                  cnicNumber: cnicNumber, cnicInfo: cnicInfo)
        let viewController = KYCReviewDetailsViewController(themeService: themeService,
                                                            viewModel: viewModel)

        return viewController
    }
}

extension KYCFeatureContainer {
    func makeMotherQuestionViewController() -> KYCQuestionsViewController {
        return MotherQuestionModuleBuilder(container: self).viewController()
    }

    func makeCityQuestionViewController(motherName: String) -> KYCQuestionsViewController {
        return CityQuestionModuleBuilder(container: self, motherName: motherName).viewController()
    }

    func makeSelfieGuidelineViewController() -> SelfieGuidelineViewController {
        SelfieGuidelineModuleBuilder(container: self).viewController()
    }

    func makeCaptureViewController() -> CaptureViewController {
        CaptureSelfieModuleBuilder(container: self).viewController()
    }

    func makeReviewSelfieViewController(image: UIImage) -> ReviewSelfieViewController {
        ReviewSelfieModuleBuilder(container: self, image: image).viewController()
    }

    func makeCardNameViewController() -> CardNameViewController {
        CardNameModuleBuilder(container: self).viewController()
    }

    func makeEditCardNameViewController() -> EditCardNameViewController {
        EditCardNameModuleBuilder(container: self).viewController()
    }

    func makeAddressViewController() -> AddressViewController {
        AddressModuleBuilder(container: self).viewController()
    }

    func makeCityListViewController() -> CityListViewController {
        CityListModuleBuilder(container: self).viewController()
    }


    func makeCardOnItsWayViewController() -> CardOnItsWayViewController {
        CardOnItsWayModuleBuilder(container: self).viewController()
    }

    func makeManualVerificationViewController() -> ManualVerificationViewController {
        ManualVerificationModuleBuilder(container: self).viewController()
    }
}