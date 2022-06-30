//
//  SendMoneySearchCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 30/06/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift

public enum SendMoneySearchType {
    case SearchType_SendMoneyBeneficiary
    case SearchType_Y2YBeneficiary
    case SearchType_YapContact
    case SearchType_None
}

class SendMoneySearchCoordinator: Coordinator<ResultType<SendMoneySearchType>> {
    
    private let root: UINavigationController
    private let result = PublishSubject<ResultType<SendMoneySearchType>>()
    private var localRoot: UINavigationController!
    
    private var container: UserSessionContainer!
    private let disposeBag = DisposeBag()
    private var beneficairies: [SearchableBeneficiaryType]!
    
    override var feature: PKCoordinatorFeature { .sendMoney }
    
    public init(root: UINavigationController, container: UserSessionContainer, beneficairies: [SearchableBeneficiaryType]) {
        self.container = container
        self.beneficairies = beneficairies
        self.root = root
    }
    
    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<SendMoneySearchType>> {
        
        let viewModel = SendMoneySearchViewModel(beneficairies)
        let viewController = SendMoneySearchViewController(self.container.themeService, viewModel: viewModel)

        root.pushViewController(viewController, animated: true)

        viewModel.outputs.cancel.subscribe(onNext: { [weak self] in
            self?.localRoot.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)

        viewModel.outputs.beneficiarySelected.subscribe(onNext: { [weak self] in
            if $0 is SendMoneyBeneficiary {
                self?.result.onNext(ResultType.success(SendMoneySearchType.SearchType_SendMoneyBeneficiary))
            }
            if $0 is Y2YRecentBeneficiary {
                self?.result.onNext(ResultType.success(SendMoneySearchType.SearchType_Y2YBeneficiary))
            }
            if $0 is YAPContact {
                self?.result.onNext(ResultType.success(SendMoneySearchType.SearchType_YapContact))
            }
        }).disposed(by: rx.disposeBag)
        
        return result
    }
}
