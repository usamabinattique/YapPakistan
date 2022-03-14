//
//  SendMoneyHomeCoordinator.swift
//  YAPPakistan
//
//  Created by Yasir on 14/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift

public enum SendMoneyType {
    case local
    case international
    case homeCountry(_ countryCode: SendMoneyBeneficiaryCountry, _ otherCountries: [SendMoneyBeneficiaryCountry]?)
    case cashPickUp
    case none
}

extension SendMoneyType: Equatable {
    public static func == (_ lhs: SendMoneyType, _ rhs: SendMoneyType) -> Bool {
        switch (lhs, rhs) {
        case (.local, .local):
            return true
        case (.international, .international):
            return true
        case (.homeCountry, .homeCountry):
            return true
        case (.cashPickUp, .cashPickUp):
            return true
        case (.none, .none):
            return true
        default:
            return false
        }
    }
}

public class SendMoneyHomeCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UIViewController
    private let result = PublishSubject<ResultType<Void>>()
    private var localRoot: UINavigationController!
    private let refreshBeneficiaries = PublishSubject<Void>()
    private let cancelFromSendMoneyFundTransfer = PublishSubject<Void>()
    private var sendOnlyOneEvent = 0
   // private var repository: SendMoneyRepositoryType!
    private let sendMoneyType: SendMoneyType!
    private var container: UserSessionContainer!
    private let disposeBag = DisposeBag()
    
   // public override var feature: CoordinatorFeature { .sendMoney }
    
    public init(root: UIViewController, container: UserSessionContainer, sendMoneyType: SendMoneyType) {
       // self.repository = repository
        self.container = container
        self.sendMoneyType = sendMoneyType
        self.root = root
    }
    
    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewModel = SendMoneyHomeViewModel(repository: container.makeYapItRepository(), sendMoneyType: sendMoneyType)
        let viewController = SendMoneyHomeViewController(themeService: container.themeService, viewModel: viewModel)
        
//        #warning("set the UIBarStyle in a proper way")
//       let statusBarStyle: UIBarStyle = SessionManager.current.currentAccountType == .household ? UIBarStyle.black : UIBarStyle.default
        
     //   localRoot = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController, themed: SessionManager.current.currentAccountType == .household, barStyle: statusBarStyle)
        
        localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        
        root.present(localRoot, animated: true, completion: nil)
        
        viewModel.outputs.close.subscribe(onNext: { [weak self] in
            self?.localRoot.dismiss(animated: true, completion: nil)
            self?.result.onNext(ResultType.cancel)
            self?.result.onCompleted()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.addBeneficiary.subscribe(onNext: { [weak self] in
           // self?.addBeneficiary()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.sendMoney.subscribe(onNext: { [weak self] in
           // self?.sendMoney($0)
            print($0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.editBeneficiary.subscribe(onNext: { [weak self] in
            //self?.editBeneficiary($0)
            print($0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.searchBeneficiaries.subscribe(onNext: { [weak self] in
          //  self?.searchBeneficiaries($0)
            print($0)
        }).disposed(by: disposeBag)
        
        refreshBeneficiaries.bind(to: viewModel.inputs.refreshObserver).disposed(by: disposeBag)
        
        return result.do(onNext: { [weak self] _ in
            self?.cancelFromSendMoneyFundTransfer.onCompleted()
        })
    }
}

private extension SendMoneyHomeCoordinator {
    
   /* func addBeneficiary() {
        coordinate(to: AddSendMoneyBeneficiaryCoordinator(root: localRoot, repository: repository, sendMoneyType: sendMoneyType)).subscribe(onNext: { [weak self] in
            if case let ResultType.success(result) = $0 {
                self?.refreshBeneficiaries.onNext(())
                if let beneficiary = result {
                    self?.sendMoney(beneficiary)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func editBeneficiary(_ beneficiary: SendMoneyBeneficiary) {
        coordinate(to: EditSendMoneyBeneficiaryCoordinator(root: localRoot, beneficiary: beneficiary, repository: repository)).subscribe(onNext: { [weak self] in
            if case ResultType.success = $0 {
                self?.refreshBeneficiaries.onNext(())
            }
        }).disposed(by: disposeBag)
    }
    
    func sendMoney(_ beneficiary: SendMoneyBeneficiary) {
        
        coordinate(to: SendMoneyFundsTransferCoordinator(root: localRoot, beneficiary: beneficiary, repository: repository)).subscribe(onNext:{ [weak self] in
            if case ResultType.success = $0 {
                self?.result.onNext(.success(()))
                self?.result.onCompleted()
            }else{
                self?.cancelFromSendMoneyFundTransfer.onNext(())
            }
        }).disposed(by: disposeBag)
    }
    
    func searchBeneficiaries(_ allBeneficiaries: [SendMoneyBeneficiary]) {
        let viewModel = SearchSendMoneyBeneficiaryViewModel(allBeneficiaries, repository: repository)
        let viewController = SearchSendMoneyBeneficiaryViewController(viewModel: viewModel)
        
        localRoot.pushViewController(viewController, animated: true)
        
        viewModel.outputs.beneficiarySelected.subscribe(onNext: { [weak self] in
            self?.sendMoney($0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.editBeneficiary.subscribe(onNext: { [weak self] in
            self?.editBeneficiary($0)
        }).disposed(by: disposeBag)
        
        refreshBeneficiaries.bind(to: viewModel.inputs.refreshObserver).disposed(by: disposeBag)
        
        cancelFromSendMoneyFundTransfer.take(1).subscribe(onNext: {[weak self] _ in
            if self?.sendOnlyOneEvent == 0 {
                viewModel.inputs.cancelPressFromSenedMoneyFundTransferObserver.onNext(())
                self?.sendOnlyOneEvent = 1
            }
        }).disposed(by: disposeBag)
    } */
}
