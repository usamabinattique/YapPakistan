//
//  TopupTransferCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 07/03/2022.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

class TopupTransferCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UINavigationController!
    private let result = PublishSubject<ResultType<Void>>()
    private let successButtonTitle: String?
    private let container: UserSessionContainer
    private let paymentGatewayModel: PaymentGatewayLocalModel
    
    init(root: UINavigationController, container: UserSessionContainer, successButtonTitle: String? = nil, paymentGatewayModel: PaymentGatewayLocalModel) {
        self.root = root
        self.container = container
        self.successButtonTitle = successButtonTitle
        self.paymentGatewayModel = paymentGatewayModel
    }
    
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewController = self.container.makeTopupTransferViewController(paymentGatewayModel: self.paymentGatewayModel)
//
//        viewModel.topupOutputs.html
//            .subscribe(onNext: { [weak self] html in
//                guard let `self` = self else { return }
//                self.navigateTo3DSEnrollment(html: html, navigationController: self.root, resultObserver: viewModel.topupInputs.pollACSResultObserver)
//            }).disposed(by: disposeBag)
//
//        viewController.viewModel.outputs.result.subscribe(onNext: { [weak self] in
//            guard let `self` = self else { return }
//            self.navigateToCVV(card: self.paymentCard, amount: Double($0.amount) ?? 0, currency: $0.currency, orderID: $0.orderId, threeDSecureId: $0.threeDSecureId, navigationController: self.root)
//        }).disposed(by: rx.disposeBag)
//
//        viewModel.outputs.cancel.subscribe(onNext: { [weak self] in
//            self?.root.popViewController(animated: true)
//            self?.result.onNext(.cancel)
//            self?.result.onCompleted()
//        }).disposed(by: disposeBag)
        
        viewController.viewModel.outputs.back
            .subscribe(onNext:{ _ in
                self.root.popViewController()
            })
            .disposed(by: rx.disposeBag)

        root.pushViewController(viewController, animated: true)
        
        return result.asObservable()
    }
}

// MARK: Navigation

//private extension TopupTransferCoordinator {
//    func navigateTo3DSEnrollment(html: String, navigationController: UINavigationController, resultObserver: AnyObserver<Void>) {
//        let viewModel: PaymentGateway3DSEnrollmentViewModelType = PaymentGateway3DSEnrollmentViewModel(html: html)
//        let viewController = PaymentGateway3DSEnrollmentViewController(viewModel: viewModel)
//        let localNavigationController = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
//
//        viewModel.outputs.complete
//            .subscribe(onNext: { _ in
//                resultObserver.onNext(())
//                localNavigationController.dismiss(animated: true)
//            }).disposed(by: disposeBag)
//
//        viewModel.outputs.back.subscribe(onNext: { _ in
//            localNavigationController.dismiss(animated: true)
//        }).disposed(by: disposeBag)
//
//        localNavigationController.modalPresentationStyle = .fullScreen
//        navigationController.present(localNavigationController, animated: true, completion: nil)
//    }
//
//    func navigateToCVV(card: ExternalPaymentCard, amount: Double, currency: String, orderID: String, threeDSecureId: String, navigationController: UINavigationController) {
//        let viewModel = TopupCardCVVViewModel(card: card, amount: amount, currency: currency, orderID: orderID, threeDSecureId: threeDSecureId)
//        let viewController = TopupCardCVVViewController(viewModel: viewModel)
//        navigationController.pushViewController(viewController, animated: true)
//
//        viewModel.outputs.result.subscribe(onNext: { [weak self] in
//            self?.navigateToTopupSuccess(amount: $0.amount, currency: $0.currency, card: $0.card, navigationController: navigationController)
//        }).disposed(by: rx.disposeBag)
//    }

//    func navigateToTopupSuccess(amount: Double, currency: String, card: ExternalPaymentCard, navigationController: UINavigationController) {
//        let viewModel = TopupSuccessViewModel(amount: amount, currency: currency, card: card, doneButtonTitle: successButtonTitle)
//        let viewController = TopupSuccessViewController(viewModel: viewModel)
//        navigationController.pushViewController(viewController, animated: true)
//
//        viewModel.outputs.back.subscribe(onNext: { [weak self] in
//            self?.root.dismiss(animated: true, completion: nil)
//            self?.result.onNext(ResultType.success(()))
//            self?.result.onCompleted()
//        }).disposed(by: disposeBag)
//
//    }
//}
