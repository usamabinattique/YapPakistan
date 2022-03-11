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

        viewController.viewModel.outputs.html
            .subscribe(onNext: { [weak self] html in
                guard let `self` = self else { return }
                print("HTML =====>",html)
                self.navigateTo3DSEnrollment(html: html, navigationController: self.root, resultObserver: viewController.viewModel.inputs.pollACSResultObserver)
            }).disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.result.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.navigateToCVV(card: self.paymentGatewayModel.beneficiary ?? ExternalPaymentCard(), amount: Double($0.amount) ?? 0, currency: $0.currency, orderID: $0.orderId, threeDSecureId: $0.threeDSecureId, navigationController: self.root)
        }).disposed(by: rx.disposeBag)

//        viewController.viewModel.outputs.cancel.subscribe(onNext: { [weak self] _ in
//            self?.root.popViewController(animated: true)
//            self?.result.onNext(.cancel)
//            self?.result.onCompleted()
//        }).disposed(by: rx.disposeBag)
        
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

private extension TopupTransferCoordinator {
    
    private func navigateTo3DSEnrollment(html: String, navigationController: UINavigationController, resultObserver: AnyObserver<Void>) {
        
        let viewModel = CommonWebViewModel(commonWebType: .topUpAddCardWeb, repository: self.container.makeCardsRepository(), html: html)
        let viewController = self.container.makeCommonWebViewController(viewModel: viewModel)
        
        viewModel.outputs.close
            .subscribe(onNext: { _ in
                viewController.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.complete
            .subscribe(onNext: { [weak self] _ in
                //show topup flow
                self?.root.dismiss(animated: false, completion: {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.64) {
                        resultObserver.onNext(())
                    }
                })
            })
            .disposed(by: rx.disposeBag)
        
        let navigationRoot = UINavigationControllerFactory.createAppThemedNavigationController(themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        navigationRoot.navigationBar.isHidden = false
        navigationRoot.pushViewController(viewController, completion: nil)
        root.present(navigationRoot, animated: true, completion: nil)
    }
    

    func navigateToCVV(card: ExternalPaymentCard, amount: Double, currency: String, orderID: String, threeDSecureId: String, navigationController: UINavigationController) {
        let viewModel = TopupCardCVVViewModel(card: card, amount: amount, currency: currency, orderID: orderID, threeDSecureId: threeDSecureId, repository: self.container.makeTransactionsRepository())
        //(card: card, amount: amount, currency: currency, orderID: orderID, threeDSecureId: threeDSecureId)
        let viewController = TopupCardCVVViewController(themeService: self.container.themeService, viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        
        viewModel.outputs.back
            .subscribe(onNext: { _ in
                navigationController.popViewController()
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.result.subscribe(onNext: { [weak self] in
            self?.navigateToTopupSuccess(amount: $0.amount, currency: $0.currency, card: $0.card, navigationController: navigationController, newBalance: $0.newBalance)
        }).disposed(by: rx.disposeBag)
    }

    func navigateToTopupSuccess(amount: Double, currency: String, card: ExternalPaymentCard, navigationController: UINavigationController, newBalance: String) {
        let viewModel = TopupSuccessViewModel(amount: amount, currency: currency, card: card, doneButtonTitle: successButtonTitle, newBalance: newBalance)
        let viewController = TopupSuccessViewController(themeService: self.container.themeService, viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)

        viewModel.outputs.back.subscribe(onNext: { [weak self] in
            self?.root.dismiss(animated: true, completion: nil)
            self?.result.onNext(ResultType.success(()))
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)

    }
}
