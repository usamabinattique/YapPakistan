//
//  KYCReviewCoordinator.swift
//  YAPPakistan
//
//  Created by Tayyab on 29/09/2021.
//

import Foundation
import RxSwift
import YAPCore

class KYCReviewCoordinator : Coordinator<ResultType<Void>> {
    private let container: KYCFeatureContainer
    private let root: UINavigationController!
    private let cnicOCR: CNICOCR

    private let resultSubject = PublishSubject<ResultType<Void>>()
    private let disposeBag = DisposeBag()

    init(container: KYCFeatureContainer,
         root: UINavigationController,
         cnicOCR: CNICOCR) {
        self.container = container
        self.root = root
        self.cnicOCR = cnicOCR
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let reviewViewController = container.makeKYCInitialReviewViewController(cnicOCR: cnicOCR)
        let reviewViewModel = reviewViewController.viewModel

        reviewViewModel.outputs.rescan
            .subscribe(onNext: { [weak self] in
                self?.root.popViewController(animated: true)

                self?.resultSubject.onNext(.cancel)
                self?.resultSubject.onCompleted()
            })
            .disposed(by: disposeBag)

        reviewViewModel.outputs.cnicInfo
            .subscribe(onNext: { _ in
                // FIXME: Perform navigation to full review.
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

                self?.resultSubject.onNext(.cancel)
                self?.resultSubject.onCompleted()
            })
            .disposed(by: disposeBag)

        return resultSubject
    }
}
