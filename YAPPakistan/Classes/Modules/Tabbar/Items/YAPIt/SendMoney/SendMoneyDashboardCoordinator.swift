//
//  SendMoneyDashboardCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 04/01/2022.
//

import Foundation
import YAPComponents
import YAPCore
import RxSwift
import RxTheme

class SendMoneyDashboardCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UIViewController
    private var localRoot: UINavigationController!
    private let successButtonTitle: String?
    private let result = PublishSubject<ResultType<Void>>()
    private var container: UserSessionContainer!
    let contactsManager: ContactsManager
    
    init(root: UIViewController, container: UserSessionContainer, successButtonTitle: String? = nil, contactsManager: ContactsManager) {
        self.root = root
        self.successButtonTitle = successButtonTitle
        self.container = container
        self.contactsManager = contactsManager
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = SendMoneyDashboardViewModel(container.makeYapItRepository(), contactsManager: self.contactsManager, accountProvider: container.accountProvider)
        
        let viewController = SendMoneyDashboardViewController(themeService: container.themeService, viewModel: viewModel, recentBeneficiaryView:container.makeRecentBeneficiaryView())
        
        self.localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        
        self.root.present(self.localRoot, animated: true, completion: nil)
        
        viewModel.outputs.action
            .subscribe(onNext: { [weak self] in
//                guard let `self` = self else { return }
                switch $0 {
                case .localTransfer:
                    print("Local")
                    //self.sendMoneyLocally(localRoot: self.localRoot, refreshObserver: viewModel.inputs.refreshObserver)
                case .internationalTransfer:
                    print("Int")
                    //self.sendMoneyInternationally(localRoot: self.localRoot, refreshObserver: viewModel.inputs.refreshObserver)
                case .qrCode:
                    print("QR")
                    //self.sendMoneyViaQrCode(localRoot: self.localRoot)
                default:
                    break
                }
            }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.action
            .withLatestFrom(Observable.combineLatest(viewModel.outputs.action, viewModel.outputs.y2yRecentBeneficiaries, viewModel.outputs.y2yContacts))
            .subscribe(onNext: { [weak self] in
                guard let localRoot = self?.localRoot else { return }
                self?.y2y(localRoot: localRoot, refreshObserver: viewModel.inputs.refreshObserver, recentBeneficiaries: $0.1)
            }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.search.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.search(self.localRoot, beneficairies: $0)
        }).disposed(by: rx.disposeBag)
        
        return result
    }
}

private extension SendMoneyDashboardCoordinator {
    func y2y(localRoot: UINavigationController, refreshObserver: AnyObserver<Void>, recentBeneficiaries: [Y2YRecentBeneficiary]) {
        coordinate(to: Y2YCoordinator(root: localRoot, container: self.container, repository: self.container.makeY2YRepository(), contacts: [], recentBeneficiaries: recentBeneficiaries, inviteFriendRepository: self.container.makeYapInviteFriendRepository(), presentable: false, contactsManager:contactsManager))
            .subscribe(onNext: { [weak self] in
            if case let ResultType.success(result) = $0 {
                self?.result.onNext(.success(result))
                self?.result.onCompleted()
            } else {
                refreshObserver.onNext(())
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func search(_ localRoot: UINavigationController, beneficairies: [SearchableBeneficiaryType]) {
        let viewModel = SendMoneySearchViewModel(beneficairies)
        let viewController = SendMoneySearchViewController(self.container.themeService, viewModel: viewModel)
        
        localRoot.pushViewController(viewController, animated: true)
        
        viewModel.outputs.cancel.subscribe(onNext: { [weak self] in
            self?.localRoot.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        
//        viewModel.outputs.beneficiarySelected.subscribe(onNext: { [weak self] in
//            if $0 is SendMoneyBeneficiary {
//                self?.sendMoneyFundsTransfer($0 as! SendMoneyBeneficiary, localRoot: localRoot)
//            }
//            if $0 is Y2YRecentBeneficiary {
//                self?.y2yFundsTransfer(YAPContact.contact(fromRecentBeneficiary: $0 as! Y2YRecentBeneficiary), localRoot: localRoot)
//            }
//            if $0 is YAPContact {
//                self?.y2yFundsTransfer($0 as! YAPContact, localRoot: localRoot)
//            }
//        }).disposed(by: rx.disposeBag)
    }
}
