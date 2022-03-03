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
                break
//                AppAnalytics.shared.logEvent(TopUpEvent.topUpQrCode())
//                self?.navigateToAddMoneyQRCode()
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
        viewModel.outputs.addNewCard.debug("add new card observer").withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                //move to add new card screen
                print("open add new card detail screen")
                self.addNewCardDetailWebView()
            })
            .disposed(by: rx.disposeBag)
        
        //open send money detail
        viewModel.outputs.beneficiarySelected
            .subscribe(onNext: { beneficiaryObj in
                print("open send money detail")
            })
            .disposed(by: rx.disposeBag)
        
        //info icon from card is pressed
        viewModel.outputs.openCardDetails.subscribe { obj in
            print("open card detail")
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
            .subscribe(onNext: { [weak self] _ in
                self?.localRoot.dismiss(animated: false, completion: nil)
                print("show topup flow")
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.showTopupDashboard
            .subscribe(onNext: { [weak self] _ in
                self?.localRoot.dismiss(animated: false, completion:nil)
                print("show topup DASHBOARD flow")
            })
            .disposed(by: rx.disposeBag)

        
        let navigationRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: self.root, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        navigationRoot.navigationBar.isHidden = false
        navigationRoot.pushViewController(viewController, completion: nil)
        localRoot.present(navigationRoot, animated: true, completion: nil)
    }
}


