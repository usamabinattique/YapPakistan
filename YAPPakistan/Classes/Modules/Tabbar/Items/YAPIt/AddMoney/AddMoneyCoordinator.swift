//
//  AddMoneyCoordinator.swift
//  YAPPakistan
//
//  Created by Yasir on 08/02/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift

class AddMoneyCoordinator: Coordinator<ResultType<Void>> {
    
//    override var feature: CoordinatorFeature { .topUp }
    
//    init(root: UIViewController, successButtonTitle: String? = nil) {
//        self.root = root
//        self.successButtonTitle = successButtonTitle
//    }
    
    private let root: UIViewController
    private var localRoot: UINavigationController!
    private let successButtonTitle: String?
    private let result = PublishSubject<ResultType<Void>>()
    private var container: UserSessionContainer!
    let contactsManager: ContactsManager
    private let repository: Y2YRepositoryType
    
    init(root: UIViewController, container: UserSessionContainer, successButtonTitle: String? = nil, contactsManager: ContactsManager, repository: Y2YRepositoryType) {
        self.root = root
        self.successButtonTitle = successButtonTitle
        self.container = container
        self.contactsManager = contactsManager
        self.repository = repository
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        
        let viewModel = AddMoneyViewModel()
        let viewControlelr = AddMoneyViewController(themeService: container.themeService, viewModel: viewModel)
        
        localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewControlelr, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        
        root.present(localRoot, animated: true, completion: nil)
        
        
//        viewModel.outputs.close.subscribe(onNext: { [weak self] in
//            self?.localRoot.dismiss(animated: true, completion: nil)
//            self?.result.onNext(.cancel)
//            self?.result.onCompleted()
//        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.action.subscribe(onNext: { [weak self] in
            switch $0 {
            case .bankTransfer:
                break
//                AppAnalytics.shared.logEvent(TopUpEvent.topUpBankTapped())
//                self?.navigateToBankDetails()
            case .topupViaCard:
//                AppAnalytics.shared.logEvent(TopUpEvent.topUpCardTapped())
                self?.navigateToCardTransfer()
            case .cashOrCheque:
                break
//                self?.navigateToLocateATM()
            case .qrCode:
//                AppAnalytics.shared.logEvent(TopUpEvent.topUpQrCode())
                self?.navigateToAddMoneyQRCode()
            case .localTransfer, .internationalTransfer, .homeCountry, .yapContact, .requestMoeny:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        
        return result.asObservable()
    }
}

private extension AddMoneyCoordinator {
    
    func navigateToCardTransfer() {
        let viewModel = TopupCardSelectionViewModel(repository: self.repository)
        let viewController = TopupCardSelectionViewController(themeService: container.themeService, viewModel: viewModel)
        localRoot.pushViewController(viewController, animated: true)
        
        //Add new card
        viewModel.outputs.addNewCard.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                //move to add new card screen
                self.addNewCardDetailWebView()
            })
            .disposed(by: rx.disposeBag)
        
        //open send money detail
        viewModel.outputs.beneficiarySelected
            .subscribe(onNext: { beneficiaryObj in
                let paymentGatewayM = PaymentGatewayLocalModel(beneficiary:beneficiaryObj)
                _ = self.showTopupTransfer(paymentGatewayModel: paymentGatewayM)
            })
            .disposed(by: rx.disposeBag)
        
        //info icon from card is pressed
        viewModel.outputs.openCardDetails.withUnretained(self).subscribe { `self`, externalCardObj in
            self.showTopupCardDetail(externalCard: externalCardObj)
        }.disposed(by: rx.disposeBag)
        
        viewModel.outputs.back
            .subscribe(onNext:{ _ in
                self.localRoot.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    private func addNewCardDetailWebView() {
        
        let apiConfig = self.container.parent.makeAPIConfiguration()
        
        let viewModel = CommonWebViewModel(commonWebType: .topUpAddCardWeb, repository: self.container.makeCardsRepository(), html: apiConfig.topUpCardDetailWebURL)
        let viewController = self.container.makeCommonWebViewController(viewModel: viewModel)
        
        viewModel.outputs.close
            .subscribe(onNext: { [weak self] _ in
                viewController.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.showTopup
            .subscribe(onNext: { [weak self] externalCardObj in
                //show topup flow
                self?.localRoot.dismiss(animated: false, completion: {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.64) {
                        let paymentGatewayM = PaymentGatewayLocalModel(beneficiary:externalCardObj)
                        _ = self?.showTopupTransfer(paymentGatewayModel: paymentGatewayM)
                    }
                })
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.showTopupDashboard
            .subscribe(onNext: { [weak self] _ in
                //show topup DASHBOARD flow
                self?.localRoot.dismiss(animated: false, completion:nil)
            })
            .disposed(by: rx.disposeBag)

        
        let navigationRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: self.root, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        navigationRoot.navigationBar.isHidden = false
        navigationRoot.pushViewController(viewController, completion: nil)
        localRoot.present(navigationRoot, animated: true, completion: nil)
    }
    
    func showTopupCardDetail(externalCard: ExternalPaymentCard) {
        let viewController = self.container.makeTopupCardDetailViewController(externalCard: externalCard)

        let navigationRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: self.root, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        navigationRoot.navigationBar.isHidden = false
        navigationRoot.pushViewController(viewController, completion: nil)
        localRoot.present(navigationRoot, animated: true, completion: nil)
        
        viewController.viewModel.outputs.close.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.localRoot.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func showTopupTransfer(paymentGatewayModel: PaymentGatewayLocalModel = PaymentGatewayLocalModel()) -> Observable<ResultType<Void>>  {
        print("show topup transfer")
        return coordinate(to: container.makeTopupTransferCoordinator(root: self.localRoot, paymentGatewayModel: paymentGatewayModel))
    }
    
    func navigateToAddMoneyQRCode() {
        coordinate(to: AddMoneyQRCodeCoordinator(root: localRoot, scanAllowed: true, container: container)).subscribe().disposed(by: rx.disposeBag)
    }
}


