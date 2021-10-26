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
            .subscribe(onNext: { $0.0.selfieGuideline() })
            .disposed(by: rx.disposeBag)

        homeViewController.viewModel.outputs.next.filter({ $0 == .cardNamePending })
            .withUnretained(self)
            .subscribe(onNext: { $0.0.cardName() })
            .disposed(by: rx.disposeBag)

        homeViewController.viewModel.outputs.next.filter({ $0 == .addressPending })
            .withUnretained(self)
            .subscribe(onNext: { $0.0.address() })
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
                self.setProgressViewHidden(true)
                self.root.setViewControllers(viewControllers, animated: true)

                // FIXME: Initiate questions flow.
                self.motherNameQuestion()

            case .cancel: break
            }
        }).disposed(by: rx.disposeBag)
    }

    func motherNameQuestion() {
        let viewController = container.makeMotherQuestionViewController()

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { $0.0.cityQuestion() })
            .disposed(by: rx.disposeBag)

        addChildVC(viewController, progress: 0.5)

    }

    func cityQuestion() {

        let viewController = container.makeCityQuestionViewController()

        viewController.viewModel.outputs.next.withUnretained(self)
            .do(onNext: { [unowned self] _ in
                self.setProgressViewHidden(true)
                let viewControllers = self.kycProgressViewController.childNavigation.viewControllers
                self.kycProgressViewController.childNavigation
                    .setViewControllers([viewControllers.first!], animated: true)
            }).delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { `self`, _ in self.selfieGuideline() })
            .disposed(by: rx.disposeBag)

        addChildVC(viewController, progress: 0.75)
    }

    // MARK: Checkpoint Selfie Pending
    func selfieGuideline() {
        let viewController = container.makeSelfieGuidelineViewController()

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.root.setNavigationBarHidden(true, animated: true)
                self.root.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.captureSelfie() })
            .disposed(by: rx.disposeBag)

        root.pushViewController(viewController, animated: true)
        root.setNavigationBarHidden(false, animated: true)
    }

    func captureSelfie() {
        let viewController = container.makeCaptureViewController()

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.root.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.unwrap().withUnretained(self)
            .subscribe(onNext: { `self`, image in self.reviewSelfie(image) })
            .disposed(by: rx.disposeBag)

        root.pushViewController(viewController, animated: true)
    }

    func reviewSelfie(_ image: UIImage) {
        let viewController = container.makeReviewSelfieViewController(image: image)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.root.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .do(onNext: { `self`, _ in
                var vcs = self.root.viewControllers
                vcs.removeLast()
                vcs.removeLast()
                vcs.removeLast()
                self.setProgressViewHidden(true)
                self.root.setNavigationBarHidden(true, animated: true)
                self.root.setViewControllers(vcs, animated: true)
            }).delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { `self`, _ in self.cardName() })
            .disposed(by: rx.disposeBag)

        root.pushViewController(viewController, animated: true)
    }

    func cardName() {
        let viewController = container.makeCardNameViewController()

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.root.setNavigationBarHidden(true, animated: true)
                self.root.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .do(onNext: { `self`, _ in
                var vcs = self.root.viewControllers
                vcs.removeLast()
                self.setProgressViewHidden(true)
                self.root.setNavigationBarHidden(true, animated: true)
                self.root.setViewControllers(vcs, animated: true)
            }).delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { `self`, _ in self.address() })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.edit.withUnretained(self)
            .flatMap({ `self`, _ in self.editName() })
            .bind(to: viewController.viewModel.inputs.nameObserver)
            .disposed(by: rx.disposeBag)

        root.pushViewController(viewController, animated: true)
        root.setNavigationBarHidden(false, animated: true)
    }

    func editName() -> Observable<String> {
        let viewController = container.makeEditCardNameViewController()

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.root.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        root.pushViewController(viewController, animated: true)

        let next = viewController.viewModel.outputs.next
            .do(onNext: { [weak self] _ in self?.root.popViewController(animated: true) })

        return next
    }

    func address() {
        let viewController = container.makeAddressViewController()

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.root.setNavigationBarHidden(true, animated: true)
                self.root.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)

        let citySelected = viewController.viewModel.outputs.city.withUnretained(self)
            .flatMap{ `self`, _ in self.selectCityName() }
            .share()
        citySelected.bind(to: viewController.viewModel.inputs.citySelectObserver)
            .disposed(by: rx.disposeBag)
        citySelected.subscribe(onNext: { [unowned self] _ in self.root.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        root.pushViewController(viewController, animated: true)
        root.setNavigationBarHidden(false, animated: true)
    }

    func selectCityName() -> Observable<String>  {
        let viewController = container.makeCityListViewController()

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.root.setNavigationBarHidden(true, animated: true)
                self.root.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)

        root.pushViewController(viewController, animated: true)
        root.setNavigationBarHidden(false, animated: true)

        return viewController.viewModel.outputs.next
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

    func setupPogressViewController() {
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

    func setProgressViewHidden(_ isHidden: Bool) {
        self.kycProgressViewController.viewModel.inputs.hideProgressObserver.onNext(isHidden)
    }

    func makeKYCProgressViewController() -> KYCProgressViewController {
        let childNav = UINavigationController()
        childNav.navigationBar.isHidden = true
        return self.container.makeKYCProgressViewController(navigationController: childNav)
    }
}
