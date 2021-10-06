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

    private let disposeBag = DisposeBag()
    private let result = PublishSubject<ResultType<Void>>()

    private var identityDocument: IdentityDocument?

    init(container: KYCFeatureContainer,
         root: UINavigationController) {
        self.container = container
        self.root = root
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let homeViewController = container.makeKYCHomeViewController()
        let homeViewModel = homeViewController.viewModel

        let navigationController = UINavigationController(rootViewController: homeViewController)
        navigationController.navigationBar.isHidden = true

        let progressViewController = container.makeKYCProgressViewController(navigationController: navigationController)
        let progressViewModel: KYCProgressViewModelType! = progressViewController.viewModel
        progressViewModel.inputs.hideProgressObserver.onNext(true)

        root.pushViewController(progressViewController, animated: true)

        homeViewModel.outputs.skip.subscribe(onNext: { [unowned self] _ in
            self.result.onNext(ResultType.success(()))
        }).disposed(by: disposeBag)

        homeViewModel.outputs.scanCard
            .subscribe(onNext: { [weak self] _ in
                self?.scanCard(homeViewModel: homeViewModel)
            })
            .disposed(by: disposeBag)

        homeViewModel.outputs.cnicOCR
            .subscribe(onNext: { [weak self] cnicOCR in
                self?.navigateToReview(kycMainController: progressViewController, cnicOCR: cnicOCR)
            })
            .disposed(by: disposeBag)

        homeViewModel.outputs.nextCheckPoint
            .subscribe(onNext: { _ in
                // FIXME :
            })
            .disposed(by: disposeBag)

        return result
    }

    private func scanCard(homeViewModel: KYCHomeViewModelType) {
        let scanCoordinator = CNICScanCoordinator(container: container, root: root, scanType: .new)

        coordinate(to: scanCoordinator).subscribe(onNext: { [weak self] result in
            if case let ResultType.success(result) = result {
                if let identityDocument = result.identityDocument {
                    self?.identityDocument = identityDocument
                    homeViewModel.inputs.detectOCRObserver.onNext(identityDocument)
                }
            }
        }).disposed(by: disposeBag)
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

            case .cancel:
                break
            }
        }).disposed(by: disposeBag)
    }
}
