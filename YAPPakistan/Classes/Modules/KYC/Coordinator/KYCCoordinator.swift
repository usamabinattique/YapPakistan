//
//  B2CKYCCoordinator.swift
//  YAP
//
//  Created by Zain on 17/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import CardScanner

class KYCCoordinator: Coordinator<ResultType<Void>> {
    private let container: KYCFeatureContainer
    private let root: UINavigationController!
    private let result = PublishSubject<ResultType<Void>>()

    private lazy var kycProgressViewController = makeKYCProgressViewController()
    private var identityDocument: IdentityDocument?
    private var kycHomeViewModel: KYCHomeViewModelType!

    init(container: KYCFeatureContainer,
         root: UINavigationController) {
        self.container = container
        self.root = root
        super.init()
        setupPogressViewController()
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        kycHome()
        return result
    }

    func kycHome() {

        let homeViewController = container.makeKYCHomeViewController()
        kycHomeViewModel = homeViewController.viewModel

        homeViewController.viewModel.outputs.skip.withUnretained(self)
            .subscribe(onNext: {
                $0.0.root.popViewController(animated: true)
                $0.0.result.onNext(.success(()))
                $0.0.result.onCompleted()
            }).disposed(by: rx.disposeBag)

        homeViewController.viewModel.outputs.scanCard.withUnretained(self)
            .subscribe(onNext: { $0.0.scanCard() })
            .disposed(by: rx.disposeBag)

        homeViewController.viewModel.outputs.cnicOCR.withUnretained(self)
            .subscribe(onNext: {
                $0.0.navigateToReview(kycMainController: $0.0.kycProgressViewController, cnicOCR: $0.1)
            })
            .disposed(by: rx.disposeBag)

        homeViewController.viewModel.outputs.next.filter({ $0 == .secretQuestionPending })
            .withUnretained(self)
            .subscribe(onNext: { $0.0.motherNameQuestion() })
            .disposed(by: rx.disposeBag)

        homeViewController.viewModel.outputs.next.filter({ $0 == .selfiePending })
            .withUnretained(self)
            .subscribe(onNext: { $0.0.selfiePending() })
            .disposed(by: rx.disposeBag)

        addChildVC(homeViewController)
    }

    private func scanCard() {
        let scanCoordinator = CNICScanCoordinator(container: container, root: root, scanType: .new)

        coordinate(to: scanCoordinator).subscribe(onNext: { [weak self] result in
            if case let ResultType.success(result) = result {
                if let identityDocument = result.identityDocument {
                    self?.identityDocument = identityDocument
                    self?.kycHomeViewModel.inputs.detectOCRObserver.onNext(identityDocument)
                }
            }
        }).disposed(by: rx.disposeBag)
    }

    private func navigateToReview(kycMainController: UIViewController, cnicOCR: CNICOCR) {
        guard let identityDocument = identityDocument else {
            return
        }

        let coordinator = container.makeKYCReviewCoordinator(root: root,
                                                             identityDocument: identityDocument,
                                                             cnicOCR: cnicOCR)

        coordinate(to: coordinator).subscribe(onNext: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                var viewControllers = self.root.viewControllers

                if let index = viewControllers.lastIndex(of: kycMainController) {
                    viewControllers.removeSubrange(index + 1 ..< viewControllers.count)
                }

                self.root.setViewControllers(viewControllers, animated: true)

                // FIXME: Initiate questions flow.
                self.motherNameQuestion()

            case .cancel: break
            }
        }).disposed(by: rx.disposeBag)
    }

    func motherNameQuestion() {
        let strings = KYCStrings(title: "screen_kyc_questions_mothers_name".localized,
                                 subHeading: "screen_kyc_questions_reason".localized,
                                 next: "common_button_next".localized )
        let viewModel = MotherMaidenNamesViewModel(accountProvider: container.accountProvider,
                                                   kycRepository: container.makeKYCRepository(),
                                                   strings: strings)
        let viewController = KYCQuestionsViewController(themeService: container.themeService, viewModel: viewModel)

        viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { $0.0.cityQuestion() })
            .disposed(by: rx.disposeBag)

        addChildVC(viewController, progress: 0.5)

    }

    func cityQuestion() {
        let strings = KYCStrings(title: "screen_kyc_questions_city_of_birth".localized,
                                 subHeading: "screen_kyc_questions_reason".localized,
                                 next: "common_button_next".localized )
        let viewModel = CityOfBirthNamesViewModel(accountProvider: container.accountProvider,
                                             kycRepository: container.makeKYCRepository(),
                                             strings: strings)
        viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { [unowned self] _ in
                let viewControllers = self.kycProgressViewController.childNavigation.viewControllers
                self.kycProgressViewController.childNavigation.setViewControllers([viewControllers.first!], animated: true)
                self.selfiePending()
            })
            .disposed(by: rx.disposeBag)

        let viewController = KYCQuestionsViewController(themeService: container.themeService, viewModel: viewModel)

        addChildVC(viewController, progress: 0.75)
    }

    // MARK: Checkpoint Selfie Pending
    func selfiePending() {
        let viewController = SelfieViewController()
        addChildVC(viewController, progress: 0.86)
    }
}

// MARK: Helpers

fileprivate extension KYCCoordinator {
    func addChildVC(_ viewController: UIViewController, progress: Float? = nil ) {
        if progress == nil {
            kycProgressViewController.childNavigation.pushViewController(viewController, animated: false)
            kycProgressViewController.viewModel.inputs.hideProgressObserver.onNext(true)
        } else {
            kycProgressViewController.childNavigation.pushViewController(viewController, animated: true)
            kycProgressViewController.viewModel.inputs.hideProgressObserver.onNext(false)
            kycProgressViewController.viewModel.inputs.progressObserver.onNext(progress!)
        }
    }

    private func setupPogressViewController() {
        self.root.pushViewController(self.kycProgressViewController, animated: true)
        kycProgressViewController.viewModel.outputs.backTap.withUnretained(self)
            .subscribe(onNext: {
                $0.0.kycProgressViewController.childNavigation.popViewController(animated: true)
                let count = $0.0.kycProgressViewController.childNavigation.viewControllers.count
                $0.0.kycProgressViewController.viewModel.inputs.progressObserver.onNext(Float(count) / 4)
                if count <= 1 {
                    $0.0.kycProgressViewController.viewModel.inputs.hideProgressObserver.onNext(true)
                }
            })
            .disposed(by: rx.disposeBag)
    }

    func makeKYCProgressViewController() -> KYCProgressViewController {
        let childNav = UINavigationController()
        childNav.navigationBar.isHidden = true
        return self.container.makeKYCProgressViewController(navigationController: childNav)
    }
}
