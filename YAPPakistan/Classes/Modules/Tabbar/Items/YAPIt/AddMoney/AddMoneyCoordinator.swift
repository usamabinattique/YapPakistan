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
        
    }
}


