//
//  EditSendMoneyBeneficiaryCoordinator.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 15/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift

class EditSendMoneyBeneficiaryCoordinator: Coordinator<ResultType<Void>> {
    
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
        
        let viewController = container.makeEditSendMoneyBeneficiaryViewController(sendMoneyType: sendMoneyType,
                                                                                  beneficiary: beneficiary)
        
        self.localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        
        self.root.present(self.localRoot, animated: true, completion: nil)
        
        viewController.viewModel.outputs.back.subscribe(onNext: { [weak self] in
            self?.localRoot.dismiss(animated: true, completion: nil)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.result.subscribe(onNext: { [weak self] status in
            self?.result.onNext(.success(()))
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        return result
    }
}
