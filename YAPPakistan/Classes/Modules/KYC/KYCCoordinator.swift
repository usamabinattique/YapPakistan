//
//  B2CKYCCoordinator.swift
//  YAP
//
//  Created by Zain on 17/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxTheme
import YAPCardScanner
import YAPCore
import YAPComponents

class KYCCoordinator: Coordinator<ResultType<Void>> {
    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController!
    private let container: KYCFeatureContainer
    private var paymentGatewayM: PaymentGatewayLocalModel!
    private var isPresented = false

    init(container: KYCFeatureContainer, root: UINavigationController) {
        self.container = container
       
        self.root = root
        self.paymentGatewayM = PaymentGatewayLocalModel()
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewController = container.makeKYCHomeViewController()
        viewController.hidesBottomBarWhenPushed = true
        root.pushViewController(viewController, animated: true)

        // Go Back
        viewController.viewModel.outputs.skip.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.goBack() })
            .disposed(by: rx.disposeBag)

        // CP01 ScanCard/OCR
        let cp1 = viewController.viewModel.outputs.scanCard.withUnretained(self)
            .flatMap({ `self`, _ in self.cnicScanOcrReview().materialize() })
        // CP02 Questions
        let cp2 = viewController.viewModel.outputs.next
            .filter({ $0 == .secretQuestionPending }).withUnretained(self)
            .flatMap({ `self`, _ in self.secretQuestionPending().materialize() })
        // CP03 Capture Selfie
        let cp3 = viewController.viewModel.outputs.next
            .filter({ $0 == .selfiePending }).withUnretained(self)
            .flatMap({ `self`, _ in self.selfiePending().materialize() })
        // CP04 Card scheme
//        let cp4 = viewController.viewModel.outputs.next
//            .filter({ $0 == .cardNamePending }).withUnretained(self)
//            .flatMap({ `self`, _ in self.cardNamePending().materialize() })
        // CP05 Card Scheme
        let cp5 = viewController.viewModel.outputs.next
            .filter({ $0 == .cardSchemePending }).withUnretained(self)
            .flatMap({ `self`, _ in self.cardOrderSchemePending().materialize() })
        // CP06 Card Scheme External Card
        let cp6 = viewController.viewModel.outputs.next
            .filter({ $0 == .cardSchemeExternalCardPending }).withUnretained(self)
            .flatMap({ `self`, _ in  self.cardOrderSchemePending().materialize() }) //self.carTopupCardSelection(isPresented: true).materialize() })
        // CP07 address
        let cp7 = viewController.viewModel.outputs.next
            .filter({ $0 == .addressPending }).withUnretained(self)
            .flatMap({
                `self`, _ in self.addressPending().materialize()
            })
        viewController.viewModel.outputs.next
            .filter({ $0.stepValue > AccountStatus.addressPending.stepValue }).withUnretained(self)
            .flatMap({ `self`, _ in self.kycResult().materialize() }).withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.goToHome() })
            .disposed(by: rx.disposeBag)
        
        let sharedCPs = Observable.merge(cp1, cp2, cp3, cp5, cp6, cp7).elements().share()

        sharedCPs.filter({ $0.isCancel }).withUnretained(self) // moved back with completing
            .subscribe(onNext: { `self`, _ in
                if !self.isPresented {
                    self.root.popViewController(animated: true)
                }
            })
            .disposed(by: rx.disposeBag)

        let cpSuccess = sharedCPs.map({ $0.isSuccess }).unwrap().share() // completed successfully

        cpSuccess
            .bind(to: viewController.viewModel.inputs.reloadAndNextObserver)
            .disposed(by: rx.disposeBag)

        Observable.zip(cpSuccess, viewController.viewModel.outputs.next) // CleanUp
            .delay(.milliseconds(500), scheduler: MainScheduler.instance).withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                let vcs = self.root.viewControllers
                self.root.viewControllers.removeSubrange(2..<(vcs.count - 1))
            }).disposed(by: rx.disposeBag)

        return result
    }
}

// MARK: Helpers
extension KYCCoordinator {

    func goBack() {
        root.popViewController(animated: true)
        self.result.onNext(.success(()))
        result.onCompleted()
    }

    func goToHome() {
        self.root.popToRootViewController(animated: true)
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }

    fileprivate func cnicScanOcrReview() -> Observable<ResultType<Void>> {
        func coordinateToCNICScan() -> Observable<Event<ResultType<IdentityScannerResult>>> {
            let coordinator = CNICScanCoordinator(container: container, root: root, scanType: .new)
            return coordinate(to: coordinator).materialize()
        }
        func coordinateToCNICOCR(document: IdentityDocument, cincOCR: CNICOCR) -> Observable<ResultType<Void>> {
            let coordinator = container.makeKYCReviewCoordinator(root: root,
                                                                 identityDocument: document,
                                                                 cnicOCR: cincOCR)
            return coordinate(to: coordinator).materialize().elements()
        }

        guard let viewController = root.topViewController as? KYCHomeViewController else {
            fatalError("FIXME: Unexpededly found nil while unraping")
        }

        let identityDocument = Observable<Void>.just(()).concat(Observable.never())
            .flatMap { _ in coordinateToCNICScan() }.elements()
            .map{ $0.isSuccess?.identityDocument }.unwrap().share()

        identityDocument
            .bind(to: viewController.viewModel.inputs.detectOCRObserver)
            .disposed(by: rx.disposeBag)

        // CNIC OCR Coordinator
        return Observable.zip(identityDocument, viewController.viewModel.outputs.cnicOCR)
            .flatMap({ coordinateToCNICOCR(document: $0, cincOCR: $1) })
    }

    func secretQuestionPending() -> Observable<ResultType<Void>> {
        return coordinate(to: container.makeKYCQuestionsCoordinator(root: root))
    }

    func selfiePending() -> Observable<ResultType<Void>>  {
        return coordinate(to: container.makeSelfieCoordinator(root: root))
    }
    
    func cardOrderSchemePending() -> Observable<ResultType<Void>>  {
        return coordinate(to: container.makeCardSchemeCoordinator(root: root, paymentGatewayM: self.paymentGatewayM))
    }
    
    func confirmPayment() -> Observable<ResultType<Void>>  {
        return coordinate(to: container.makeConfirmPaymentCoordinator(root: root, paymentGatewayM: paymentGatewayM))
    }
    
    func carTopupCardSelection(isPresented : Bool) -> Observable<ResultType<Void>>  {
        self.isPresented = isPresented
        return coordinate(to: container.makeTopupCardSelectionCoordinator(root: root, paymentGatewayM: paymentGatewayM))
    }

    func addressPending() -> Observable<ResultType<Void>> {
        return coordinate(to: container.makeAddressCoordinator(root: root, paymentGatewayM: self.paymentGatewayM))
    }

    func kycResult() -> Observable<ResultType<Void>> {
        return coordinate(to: KYCResultCoordinator(root: root, container: container))
    }
}
