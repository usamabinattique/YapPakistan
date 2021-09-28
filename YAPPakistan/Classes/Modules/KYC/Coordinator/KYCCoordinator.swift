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
    var container: UserSessionContainer
    var root: UINavigationController!
    var currentRoot: UINavigationController!
    var result = PublishSubject<ResultType<Void>>()
    var errorResult = PublishSubject<Void>()
    var informationReviewResult = PublishSubject<Void>()
    var successResult: PublishSubject<Void> = PublishSubject<Void>()
    var rootViewController: UIViewController
    var cnicUploadObserver: AnyObserver<Void>?
    var initiatedFromDashboard: Bool = true

    let disposeBag = DisposeBag()

    init(container: UserSessionContainer,
         root: UINavigationController,
         cnicUploadObserver: AnyObserver<Void>? = nil,
         initiatedFromDashboard: Bool = true) {
        self.container = container
        self.rootViewController = root
        self.root = root
        self.currentRoot = root
        self.cnicUploadObserver = cnicUploadObserver
        self.initiatedFromDashboard = initiatedFromDashboard
    }

    func scanCard(_ presentationCompletion: (() -> Void)?,
                  progressViewModel: KYCProgressViewModelType,
                  homeViewModel: KYCHomeViewModelType) {
        let scanCoordinator = CNICScanCoordinator(container: container, root: currentRoot, scanType: .new)
        scanCoordinator.presentationCompletion
            .subscribe(onNext: { presentationCompletion?() })
            .disposed(by: disposeBag)

        coordinate(to: scanCoordinator).subscribe(onNext: { result in
            if case let ResultType.success(result) = result {
                if let identityDocument = result.identityDocument {
                    homeViewModel.inputs.detectOCRObserver.onNext(identityDocument)
                }
            }
        }).disposed(by: disposeBag)
    }
}

class KYCCoordinatorPushable: KYCCoordinator {
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let homeViewController = container.makeKYCHomeViewController(initiatedFromDashboard: initiatedFromDashboard)
        let homeViewModel = homeViewController.viewModel

        let navigationController = UINavigationController(rootViewController: homeViewController)
        navigationController.navigationBar.isHidden = true

        let progressViewController = container.makeKYCProgressViewController(navigationController: navigationController)
        let progressViewModel: KYCProgressViewModelType! = progressViewController.viewModel

        root.pushViewController(progressViewController, animated: true)
        rootViewController = homeViewController
        currentRoot = navigationController

        homeViewModel.outputs.skip.subscribe(onNext: { [unowned self] _ in
            self.result.onNext(ResultType.success(()))
        }).disposed(by: disposeBag)

        homeViewModel.outputs.scanCard
            .subscribe(onNext: { [weak self] _ in
                self?.scanCard(nil,
                               progressViewModel: progressViewModel,
                               homeViewModel: homeViewModel)
            })
            .disposed(by: disposeBag)

        informationReviewResult
            .bind(to: homeViewModel.inputs.documentsUploadObserver)
            .disposed(by: disposeBag)

        errorResult.subscribe(onNext: { [weak self] in
            self?.result.onNext(ResultType.success(()))
            self?.result.onCompleted()
        }).disposed(by: disposeBag)

        successResult.subscribe(onNext: { [weak self] in
            self?.result.onNext(ResultType.success(()))
            self?.result.onCompleted()
        }).disposed(by: disposeBag)

        informationReviewResult
            .subscribe(onNext: { _ in
                // FIXME: Perform navigation.
            }).disposed(by: disposeBag)

        let backSubscription = progressViewModel.outputs.backTap.subscribe(onNext: { [weak self] in
            if navigationController.viewControllers.count > 1 {
                let viewController = navigationController.popViewController(animated: true)
                viewController?.didPopFromNavigationController()

                var remainingControllers = navigationController.viewControllers.count
                remainingControllers = remainingControllers > 0 ? remainingControllers : 1

                progressViewModel.inputs.progressObserver.onNext(Float(remainingControllers) / 7)
            } else {
                progressViewModel.inputs.popppedObserver.onNext(())
                self?.root.popViewController(animated: true)
            }
        })
        backSubscription.disposed(by: disposeBag)

        return result
    }
}
