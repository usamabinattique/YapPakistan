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
        
        
      /*  viewModel.outputs.close.subscribe(onNext: { [weak self] in
            self?.localRoot.dismiss(animated: true, completion: nil)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.action.subscribe(onNext: { [weak self] in
            switch $0 {
            case .bankTransfer:
                AppAnalytics.shared.logEvent(TopUpEvent.topUpBankTapped())
                self?.navigateToBankDetails()
            case .topupViaCard:
                AppAnalytics.shared.logEvent(TopUpEvent.topUpCardTapped())
                self?.navigateToCardTransfer()
            case .cashOrCheque:
                self?.navigateToLocateATM()
            case .qrCode:
                AppAnalytics.shared.logEvent(TopUpEvent.topUpQrCode())
                self?.navigateToAddMoneyQRCode()
            case .localTransfer, .internationalTransfer, .homeCountry, .yapContact:
                break
            }
        }).disposed(by: rx.disposeBag) */
        
        
        return result.asObservable()
    }
}
/*
private extension AddMoneyCoordinator {
    
    func navigateToBankDetails() {
        let viewModel = TopUpAccountDetailsViewModel()
        let viewController = TopUpAccountDetailsViewController(with: viewModel)
        localRoot.pushViewController(viewController, animated: true)
    }
    
    func navigateToCardTransfer() {
        let viewModel = TopupCardSelectionViewModel()
        let viewController = TopupCardSelectionViewController(viewModel: viewModel)
        
        viewModel.outputs.addNewCard
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.navigateToAddNewCard(navigationController: self.localRoot, resultOberver: viewModel.inputs.refreshCardsObserver)
            }).disposed(by: disposeBag)
        
        viewModel.outputs.beneficiarySelected
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                let date = Date()
                if ($0.expiryDate ?? date) > date {
                    self.navigateToTopupTransfer(beneficiary: $0, navigationController: self.localRoot)
                } else {
                    self.openCardDetails($0, navigationController: self.localRoot, refreshCards: viewModel.inputs.refreshCardsObserver)
                }
            }).disposed(by: disposeBag)
        
        viewModel.outputs.openCardDetails
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.openCardDetails($0, navigationController: self.localRoot, refreshCards: viewModel.inputs.refreshCardsObserver)
            }).disposed(by: disposeBag)
        
        localRoot.pushViewController(viewController, animated: true)
    }
    
    func navigateToAddNewCard(navigationController: UINavigationController, resultOberver: AnyObserver<Void>) {
        let viewModel: AddTopupPaymentCardViewModelType = AddTopupPaymentCardViewModel()
        let viewController = AddTopupPaymentCardViewController(viewModel: viewModel)
        let nav = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
        
        viewModel.outputs.complete
            .subscribe(onNext: { [weak self] in
                resultOberver.onNext(())
                if $0 != nil {
                    self?.navigateToTopupTransfer(beneficiary: $0!, navigationController: navigationController, animated: false)
                }
                nav.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        navigationController.present(nav, animated: true)
    }
    
    func navigateToTopupTransfer(beneficiary: ExternalPaymentCard, navigationController: UINavigationController, animated: Bool = true) {
        
        coordinate(to: TopupTransferCoordinator(root: navigationController, paymentCard: beneficiary)).subscribe(onNext: { [weak self] in
            if case let ResultType.success(result) = $0 {
                self?.localRoot.dismiss(animated: true, completion: nil)
                self?.result.onNext(ResultType.success(result))
                self?.result.onCompleted()
            }
        }).disposed(by: disposeBag)
    }
    
    func openCardDetails(_ externalCard: ExternalPaymentCard, navigationController: UINavigationController, refreshCards: AnyObserver<Void>) {
        let viewModel: TopUpCardDetailsViewModelType = TopUpCardDetailsViewModel(externalCard: externalCard)
        let viewController = TopUpCardDetailsViewController(viewModel: viewModel)
        
        let localNavigationController = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
        
        viewModel.outputs.close
            .do(onNext: { _ in localNavigationController.dismiss(animated: true, completion: nil)})
            .filter {
                if case ResultType.success = $0 { return true }
                return false }
            .subscribe(onNext: {_ in
                refreshCards.onNext(())
            })
            .disposed(by: disposeBag)
        
        localNavigationController.modalPresentationStyle = .fullScreen
        navigationController.present(localNavigationController, animated: true, completion: nil)
    }
    
    func navigateToLocateATM() {
        coordinate(to: LocateATMCDMCoordinator(rootViewController: localRoot, locatorType: .cdm)).subscribe().disposed(by: disposeBag)
    }
    
    func navigateToAddMoneyQRCode() {
        coordinate(to: AddMoneyQRCodeCoordinator(root: localRoot, scanAllowed: false)).subscribe().disposed(by: disposeBag)
    }
}

*/
