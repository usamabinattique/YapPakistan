//
//  SendMoneyFundsTransferCoordinator.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import RxTheme
import YAPComponents

class SendMoneyFundsTransferCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UIViewController
    private let sendMoneyType: SendMoneyType!
    private let container: UserSessionContainer!
    private let beneficiary: SendMoneyBeneficiary
    private var localRoot: UINavigationController!
    
    private let result = PublishSubject<ResultType<Void>>()
    
    public init(root: UIViewController, container: UserSessionContainer, beneficiary: SendMoneyBeneficiary, sendMoneyType: SendMoneyType) {
        
        self.root = root
        self.container = container
        self.beneficiary = beneficiary
        self.sendMoneyType = sendMoneyType
    }
    
    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewController = container.makeSendMoneyFundsTransferViewController(sendMoneyType: sendMoneyType, beneficiary: beneficiary)
        
        
        
        //.makeEditSendMoneyBeneficiaryViewController(sendMoneyType: sendMoneyType,
                                                                                  //beneficiary: beneficiary)
        
        self.localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        
        self.root.present(self.localRoot, animated: true, completion: nil)
        
        viewController.viewModel.outputs.back.subscribe(onNext: { [weak self] in
            self?.localRoot.dismiss(animated: true, completion: nil)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
//
//        viewController.viewModel.outputs.result.subscribe(onNext: { [weak self] status in
//            self?.localRoot.dismiss(animated: true, completion: nil)
//            self?.result.onNext(.success(()))
//            self?.result.onCompleted()
//        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.selectReason.subscribe(onNext:{ [weak self] in
            self?.selectReason($0, viewController.viewModel.inputs.reasonSelectedObserver)
        }).disposed(by: rx.disposeBag)
        
        return result
    }
    
//    func selectReason(_ reasons: [TransferReasonType], _ selectedReasonObserver: AnyObserver<TransferReason>) {
//        let viewModel = SMFTPOPSelectionViewModel(reasons)
//        let viewController = SMFTPOPSelectionViewController(with: viewModel)
//        viewController.show(in: localRoot)
//
//        viewModel.outputs.popSelected
//            .subscribe(onNext: { selectedReasonObserver.onNext($0) })
//            .disposed(by: disposeBag)
//    }
    
    func selectReason(_ reasons: [TransferReason], _ selectedReasonObserver: AnyObserver<TransferReason>) {
        let viewModel = SMFTPOPSelectionViewModel(reasons)
        let viewController = SMFTPOPSelectionViewController(viewModel, themeService: container.themeService)
        viewController.show(in: localRoot)
        
        viewModel.outputs.popSelected
            .subscribe(onNext: { selectedReasonObserver.onNext($0) })
            .disposed(by: rx.disposeBag)
    }
}

//public class SendMoneyFundsTransferCoordinator: Coordinator<ResultType<Void>> {
//    let result = PublishSubject<ResultType<Void>>()
//    let root: UINavigationController!
//    let beneficiary: SendMoneyBeneficiary
//    var localRoot: UINavigationController!
//    var repository: SendMoneyRepositoryType!
//
//    public override var feature: CoordinatorFeature {
//        switch self.beneficiary.type ?? .domestic {
//        case .domestic:
//            return .sendMoneyTransfer(.domestic)
//        case .uaefts:
//            return .sendMoneyTransfer(.uaefts)
//        case .rmt:
//            return .sendMoneyTransfer(.rmt)
//        case .swift:
//            return .sendMoneyTransfer(.swift)
//        case .cashPayout:
//            return .sendMoneyTransfer(.domestic)
//        case .IBFT
//            return .sendMoneyTransfer(.domestic)
//        }
//    }
//
//    public init(root: UINavigationController, beneficiary: SendMoneyBeneficiary, repository: SendMoneyRepositoryType = SendMoneyRepository()) {
//        self.root = root
//        self.beneficiary = beneficiary
//        self.repository = repository
//    }
//
//    public override func start() -> Observable<ResultType<Void>> {
//
//        let viewModel: SendMoneyFundsTransferViewModel
//
//        if beneficiary.type == .cashPayout {
//            viewModel = SendMoneyCashPickupViewModel(beneficiary, repository: self.repository)
//        } else {
//            if beneficiary.country! == "AE" {
//                viewModel = SendMoneyLocalTransferViewModel(beneficiary, repository: self.repository)
//            } else {
//                viewModel = SendMoneyInternationalTransferViewModel(beneficiary, repository: self.repository)
//            }
//        }
//
//        let viewController = SendMoneyFundsTransferViewController(viewModel)
//        localRoot = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController, themed: SessionManager.current.currentAccountType == .household )
//        localRoot.interactivePopGestureRecognizer?.isEnabled  = false
//        root.present(localRoot, animated: true, completion: nil)
//
//        viewModel.outputs.back.subscribe(onNext: { [weak self] in
//            self?.localRoot.dismiss(animated: true, completion: nil)
//            self?.result.onNext(ResultType.cancel)
//            self?.result.onCompleted()
//        }).disposed(by: disposeBag)
//
//        viewModel.outputs.otp.subscribe(onNext: { [weak self] in
//            self?.navigateToOTP($0.0, $0.1, result: viewModel.inputs.otpVerifiedObsever)
//        }).disposed(by: disposeBag)
//
//        viewModel.outputs.result.subscribe(onNext: { [weak self] in
//            AppAnalytics.shared.logEvent(SendMoneyEvent.confirmAmount())
//            self?.navigateToSuccess($0)
//        }).disposed(by: disposeBag)
//
//        viewModel.outputs.selectReason.subscribe(onNext:{ [weak self] in
//            self?.selectReason($0, viewModel.inputs.reasonSelectedObserver)
//        }).disposed(by: disposeBag)
//
//        return result.asObservable()
//    }
//}
//
//// MARK: Navigation
//
//private extension SendMoneyFundsTransferCoordinator {
//    func selectReason(_ reasons: [TransferReasonType], _ selectedReasonObserver: AnyObserver<TransferReason>) {
//        let viewModel = SMFTPOPSelectionViewModel(reasons)
//        let viewController = SMFTPOPSelectionViewController(with: viewModel)
//        viewController.show(in: localRoot)
//
//        viewModel.outputs.popSelected
//            .subscribe(onNext: { selectedReasonObserver.onNext($0) })
//            .disposed(by: disposeBag)
//    }
//
//    func navigateToOTP(_ beneficairy: SendMoneyBeneficiary, _ amount: Double, result: AnyObserver<Void>) {
//        let action: OTPAction
//        switch beneficairy.type ?? .domestic {
//        case .domestic:
//            action = .domesticTransfer
//        case .uaefts:
//            action = .uaefts
//        case .cashPayout:
//            action = .cashPayout
//        case .rmt:
//            action = .rmt
//        case .swift:
//            action = .swift
//        }
//        let viewModel = YapItOTPViewModel(otpAction: action, beneficiary: beneficairy, transferAmount: amount)
//        let viewController = YapItOTPViewController(viewModel: viewModel)
//        let nav = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
//        localRoot.present(nav, animated: true, completion: nil)
//
//        viewModel.outputs.completed.subscribe(onNext:{ result.onNext(()) }).disposed(by: disposeBag)
//    }
//
//    func navigateToSuccess(_ result: SendMoneyTransactionResult) {
//        switch result.beneficiary.type ?? .domestic {
//        case .cashPayout:
//            success(result)
//        case .rmt, .swift, .uaefts, .domestic:
//            confirmation(result)
//        }
//    }
//
//    func confirmation(_ result: SendMoneyTransactionResult) {
//        let viewModel = SMFTConfirmViewModel(result, repository: self.repository)
//        let viewController = SMFTConfirmViewController(viewModel: viewModel)
//        localRoot.pushViewController(viewController, animated: true)
//
//        viewModel.outputs.result.subscribe(onNext: { [weak self] in
//            self?.success($0)
//        }).disposed(by: disposeBag)
//
//        viewModel.outputs.otp.subscribe(onNext: { [weak self] in
//            self?.navigateToOTP($0.0, $0.1, result: viewModel.inputs.otpVerifiedObsever)
//        }).disposed(by: disposeBag)
//
//        viewModel.outputs.openTerms.subscribe(onNext: { [weak self] in
//            self?.termsAndConditions()
//        }).disposed(by: disposeBag)
//    }
//
//    func success(_ result: SendMoneyTransactionResult) {
//        let viewModel = SendMoneyFundsTransferSuccessViewModel(result)
//        let viewController = SendMoneyFundsTransferSuccessViewController(viewModel: viewModel)
//        localRoot.pushViewController(viewController, animated: true)
//
//        viewModel.outputs.goToDashboard.subscribe(onNext: { [weak self] in
//            self?.result.onNext(.success(()))
//            self?.result.onCompleted()
//        }).disposed(by: disposeBag)
//    }
//
//    func termsAndConditions() {
//        var url = URL(string: (Bundle.main.object(forInfoDictionaryKey: "AppTermsAndConditions") as? String) ?? "")
//        url?.appendPathComponent("transfers")
//        coordinate(to: TermsAndConditionCoordinator(root: localRoot, termsURL: url)).subscribe().disposed(by: disposeBag)
//    }
//}
