//
//  KYCReviewCoordinator.swift
//  YAPPakistan
//
//  Created by Tayyab on 29/09/2021.
//

import CardScanner
import Foundation
import RxSwift
import YAPCore

class KYCReviewCoordinator : Coordinator<ResultType<Void>> {
    private let container: KYCFeatureContainer
    private let root: UINavigationController!
    private let identityDocument: IdentityDocument
    private let cnicOCR: CNICOCR

    private let resultSubject = PublishSubject<ResultType<Void>>()
    private let disposeBag = DisposeBag()

    init(container: KYCFeatureContainer,
         root: UINavigationController,
         identityDocument: IdentityDocument,
         cnicOCR: CNICOCR) {
        self.container = container
        self.root = root
        self.identityDocument = identityDocument
        self.cnicOCR = cnicOCR
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let reviewViewController = container.makeKYCInitialReviewViewController(cnicOCR: cnicOCR)
        let reviewViewModel = reviewViewController.viewModel

        reviewViewModel.outputs.rescan
            .subscribe(onNext: { [weak self] in
                self?.resultSubject.onNext(.cancel)
                self?.resultSubject.onCompleted()
            })
            .disposed(by: disposeBag)

        reviewViewModel.outputs.cnicInfo
            .subscribe(onNext: { [weak self] cnicInfo in
                guard let self = self else { return }
                self.navigateToReviewDetails(cnicNumber: self.cnicOCR.cnicNumber, cnicInfo: cnicInfo)
            })
            .disposed(by: disposeBag)

        let navigationController = UINavigationController(rootViewController: reviewViewController)
        navigationController.navigationBar.isHidden = true

        let progressViewController = container.makeKYCProgressViewController(navigationController: navigationController)
        let progressViewModel: KYCProgressViewModelType! = progressViewController.viewModel
        progressViewModel.inputs.progressObserver.onNext(0.25)

        root.pushViewController(progressViewController, animated: true)

        progressViewModel.outputs.backTap
            .subscribe(onNext: { [weak self] in
                self?.resultSubject.onNext(.cancel)
                self?.resultSubject.onCompleted()
            })
            .disposed(by: disposeBag)

        return resultSubject
    }

    private func navigateToReviewDetails(cnicNumber: String, cnicInfo: CNICInfo) {
        let reviewViewController = container.makeKYCReviewDetailsViewController(
            identityDocument: identityDocument, cnicNumber: cnicNumber, cnicInfo: cnicInfo)
        let reviewViewModel = reviewViewController.viewModel

        reviewViewModel.outputs.next
            .subscribe(onNext: { [weak self] in
                self?.resultSubject.onNext(.success(()))
                self?.resultSubject.onCompleted()
            })
            .disposed(by: disposeBag)

        let navigationController = UINavigationController(rootViewController: reviewViewController)
        navigationController.navigationBar.isHidden = true

        let progressViewController = container.makeKYCProgressViewController(navigationController: navigationController)
        let progressViewModel: KYCProgressViewModelType! = progressViewController.viewModel
        progressViewModel.inputs.progressObserver.onNext(0.25)

        root.pushViewController(progressViewController, animated: true)

        progressViewModel.outputs.backTap
            .subscribe(onNext: { [weak self] in
                self?.root.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
