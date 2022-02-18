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
    private var container: UserSessionContainer!
    
    private var shouldPresent: Bool = false
    
//    public override var feature: CoordinatorFeature { .y2yTransfer }
    
    public init(root: UINavigationController, container: UserSessionContainer,  repository: Y2YRepositoryType, shouldPresent: Bool? = false) {
        self.root = root
        self.repository = repository
        self.shouldPresent = shouldPresent ?? false
        self.container = container
        
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewModel = ConfirmPaymentViewModel(ConfirmPaymentViewModel.LocalizedStrings(title: "screen_yap_confirm_payment_display_text_toolbar_title".localized, subTitle: "screen_yap_confirm_payment_display_text_toolbar_subtitle".localized,cardFee: "screen_yap_confirm_payment_display_text_Card_fee".localized, payWith: "screen_yap_confirm_payment_display_text_pay_with".localized, action: "Place order for PKR 1,000"))
        let viewController = ConfirmPaymentViewController(themeService: container.themeService, viewModel: viewModel)
        if self.shouldPresent {
            self.presentConfirmPaymentController(present:viewController)
        }
        else {
        root.pushViewController(viewController, animated: true)
        }
        
//        viewModel.outputs.result.subscribe(onNext: { [weak self] in
//          //  self?.tranferSuccess($0.0, $0.1)
//        }).disposed(by: rx.disposeBag)
        
        
      /*  viewModel.outputs.close.subscribe(onNext: { [weak self] in
            if self?.shouldPresent ?? false {
                self?.root.dismiss(animated: true, completion: nil)
            } else {
                self?.root.popViewController(animated: true)
            }
            self?.result.onNext(ResultType.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag) */
        
     /*   viewModel.outputs.back.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if self.shouldPresent { self.localNavigationController.dismiss(animated: true, completion: nil) } else {
                (self.root.popViewController(animated: true)) }
            self.result.onNext(.cancel)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag) */
        
        viewModel.outputs.close.subscribe(onNext: { [weak self] in
               guard let self = self else { return }
               if self.shouldPresent { self.localNavigationController.dismiss(animated: true, completion: nil) } else {
                   (self.root.popViewController(animated: true)) }
               self.result.onNext(.cancel)
               self.result.onCompleted()
           }).disposed(by: rx.disposeBag)
        
        return result.asObservable()
    }
    
    func presentConfirmPaymentController(present: UIViewController)  {
        self.localNavigationController = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: present)
        self.root.present(self.localNavigationController, animated: true)
        
    }
}

// MARK: Navigation

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
