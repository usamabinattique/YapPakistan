//
//  SelfieCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 13/10/2021.
//

import Foundation
import RxSwift
import YAPCore

class SelfieCoordinator: Coordinator<ResultType<Void>> {
    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController!
    private let container: KYCFeatureContainer
    private let navigator: NavigationContainerViewController

    init(root: UINavigationController,
         container: KYCFeatureContainer) {
        self.container = container
        self.root = root
        self.navigator = container.makeNavigationContainerViewController()
        super.init()
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        Observable<Void>.just(()).withUnretained(self)
            .flatMap{ `self`, _ in self.selfieGuideline() }.withUnretained(self)
            .flatMap{ `self`, _ in self.captureSelfie() }.withUnretained(self)
            .flatMap{ `self`, image in self.reviewSelfie(image) }.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.moveNext() })
            .disposed(by: rx.disposeBag)

        self.root.pushViewController(navigator)

        return result
    }

    func selfieGuideline() -> Observable<Void> {
        let viewController = container.makeSelfieGuidelineViewController()
        navigator.childNavigation.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.goBack() })
            .disposed(by: rx.disposeBag)

        return viewController.viewModel.outputs.next
    }

    func captureSelfie() -> Observable<UIImage> {
        let viewController = container.makeCaptureViewController()
        navigator.childNavigation.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigator.childNavigation.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        return viewController.viewModel.outputs.next.unwrap()
    }

    func reviewSelfie(_ image: UIImage) -> Observable<Void> {
        let viewController = container.makeReviewSelfieViewController(image: image)
        navigator.childNavigation.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigator.childNavigation.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.next.subscribe(onNext: { [unowned self] _ in
            self.GotoKYCResult()
        }).disposed(by: rx.disposeBag)

        return viewController.viewModel.outputs.next
    }
    
    func GotoKYCResult() {
        //        coordinate(to: KYCResultCoordinator(root: self.root, container: self.container))
        //            .subscribe()
        //            .disposed(by: rx.disposeBag)
        
        let account = container.accountProvider.currentAccountValue.value
        if account?.isSecretQuestionVerified == true {
            let viewModel = AccountOpenSuccessViewModel()
            let viewController = AccountOpenSuccessViewController(themeService: self.container.themeService, viewModel: viewModel)
            viewModel.outputs.gotoDashboard.debug().subscribe(onNext: { [weak self] _ in
                guard let _ = self else { return }
                print("Go to dashboard function called")
                self?.root.popToRootViewController(animated: true)
            }).disposed(by: rx.disposeBag)
            self.root.pushViewController(viewController, completion: nil)
        } else {
            // self.manualVerification()
            // - Open Mannual verification ViewController here.. 
        }
    }
}

// MARK: Helpers
extension SelfieCoordinator {
    fileprivate func goBack() {
        self.result.onNext(.cancel)
        self.result.onCompleted()
    }

    func moveNext() {
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }
}
