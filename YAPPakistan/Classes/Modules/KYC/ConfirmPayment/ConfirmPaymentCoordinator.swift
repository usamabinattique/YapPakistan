//
//  ConfirmPaymentCoordinator.swift
//  YAPPakistan
//
//  Created by Yasir on 16/02/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents



public class ConfirmPaymentCoordinator: Coordinator<ResultType<Void>> {
    
    let root: UINavigationController!
    let result = PublishSubject<ResultType<Void>>()
    let repository: Y2YRepositoryType!
    var localNavigationController: UINavigationController!
    private var container: KYCFeatureContainer!
    private var paymentGatewayM: PaymentGatewayLocalModel!
    
    private var shouldPresent: Bool = false
    private var isCVVPushed = false
    
//    public override var feature: CoordinatorFeature { .y2yTransfer }
    
    public init(root: UINavigationController, container: KYCFeatureContainer,  repository: Y2YRepositoryType, shouldPresent: Bool? = false, paymentGatewayM: PaymentGatewayLocalModel? = nil) {
        self.root = root
        self.repository = repository
        self.shouldPresent = shouldPresent ?? false
        self.container = container
        self.paymentGatewayM = paymentGatewayM
        
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewModel = ConfirmPaymentViewModel(accountProvider: container.accountProvider, kycRepository: container.makeKYCRepository(), transactionRepository: container.parent.makeTransactionsRepository(), paymentGatewayObj: self.paymentGatewayM)
        let viewController = ConfirmPaymentViewController(themeService: container.themeService, viewModel: viewModel)
        if self.shouldPresent {
            self.presentConfirmPaymentController(present:viewController)
        }
        else {
            root.pushViewController(viewController, animated: true)
        }
        
        
        viewModel.outputs.showCVV.withUnretained(self).subscribe(onNext: { `self`,_ in
            guard let card = self.paymentGatewayM.beneficiary, let amount = self.paymentGatewayM.cardSchemeObject?.fee, !self.isCVVPushed else { return }
            self.isCVVPushed = true
            self.navigateToCVV(card: card, amount: amount, currency: "PKR",viewModel: viewModel)
        }).disposed(by: rx.disposeBag)

        
        viewModel.outputs.close.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.finishCoordinator(.cancel)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.edit.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.finishCoordinator(.cancel)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.next.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.finishCoordinator(.success(()))
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.html.withUnretained(self).subscribe(onNext:{ `self`, htmlString in
            self.cardDetailWeb(html: htmlString, viewModel: viewModel)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.topupComplete.withUnretained(self).subscribe(onNext: { `self`, _ in
            if self.shouldPresent {
                
                self.root.dismiss(animated: true) {
                    self.moveNext()
                }
            }
            else {
                self.root.popViewController(animated: true) {
                    self.moveNext()
                }
            }
        }).disposed(by: rx.disposeBag)
        
        return result.asObservable()
    }
    
    private func finishCoordinator(_ type: ResultType<Void>) {
        if self.shouldPresent { self.localNavigationController.dismiss(animated: true, completion: nil) } else {
            (self.root.popViewController(animated: true)) }
        self.result.onNext(type)
        self.result.onCompleted()
    }
    
    func presentConfirmPaymentController(present: UIViewController)  {
        self.localNavigationController = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: present)
        self.root.present(self.localNavigationController, animated: true)
        
    }
    
    private func cardDetailWeb(html: String, viewModel: ConfirmPaymentViewModel) {
        _ = coordinate(to: CommonWebViewCoordinator(root: self.localNavigationController, container: self.container, commonWebType: .onBoardingOTPWeb, paymentGatewayM: self.paymentGatewayM, html: html, resultObserver: viewModel.inputs.pollACSResultObserver))
    }
    
    private func navigateToCVV(card: ExternalPaymentCard ,amount: Double, currency: String, viewModel vm :ConfirmPaymentViewModel) {
        let viewModel = TopupCardCVVViewModel(card: card, amount: amount, currency: currency)
        let viewController = TopupCardCVVViewController(themeService: container.themeService, viewModel: viewModel)
        self.localNavigationController.pushViewController(viewController, completion: nil)
        viewModel.outputs.result.subscribe(onNext: { [weak self] cvv in
            self?.isCVVPushed = false
            vm.inputs.enteredCVV.onNext(cvv)
            self?.localNavigationController.popViewController()
         }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.backObservable.subscribe(onNext: { [weak self] _ in
            self?.isCVVPushed = false
            self?.localNavigationController.popViewController()
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: Navigation

fileprivate extension ConfirmPaymentCoordinator {
    func goBack() {
        self.result.onNext(.cancel)
        self.result.onCompleted()
    }

    func moveNext() {
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }
}

private extension Y2YFundsTransferCoordinator {
   /* func otp(_ contact: YAPContact, _ amount: Double, result: AnyObserver<Void>) {
        let viewModel = YapItOTPViewModel(otpAction: .y2y, beneficiary: contact, transferAmount: amount)
        let viewController = YapItOTPViewController(viewModel: viewModel)
        
        let nav = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
        root.present(nav, animated: true, completion: nil)
        
        viewModel.outputs.completed.subscribe(onNext: { result.onNext(()) }).disposed(by: disposeBag)
    }
    
    func tranferSuccess(_ contact: YAPContact, _ amount: Double) {
        let viewModel = Y2YTransferSuccessViewModel(contact, amount)
        let viewController = Y2YTransferSuccessViewController(theme: container.themeService, viewModel: viewModel)
        if self.shouldPresent {
            self.localNavigationController.pushViewController(viewController, animated: true)
        }
        else {
        root.pushViewController(viewController, animated: true)
        }
        
        viewModel.outputs.confirm.subscribe(onNext: { [weak self] in
            self?.result.onNext(ResultType.success(()))
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    } */
}

