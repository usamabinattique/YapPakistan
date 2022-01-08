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
//    let contactsManager: ContactsManager
    
    //init(root: UIViewController, successButtonTitle: String? = nil, contactsManager: ContactsManager) {
    init(root: UIViewController, container: UserSessionContainer, successButtonTitle: String? = nil) {
        self.root = root
        self.successButtonTitle = successButtonTitle
        self.container = container
//        self.contactsManager = contactsManager
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = SendMoneyDashboardViewModel(container.makeYapItRepository())
        let viewController = container.makeSendMoneyDashboardViewController()
        
        self.localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        
        self.root.present(self.localRoot, animated: true, completion: nil)
        
        viewModel.outputs.action
            .withLatestFrom(Observable.combineLatest(viewModel.outputs.action, viewModel.outputs.y2yRecentBeneficiaries, viewModel.outputs.y2yContacts))
            .subscribe(onNext: { [weak self] in
                guard case YapItTileAction.yapContact = $0.0, let localRoot = self?.localRoot else { return }
                print($0)
                //self?.y2y(localRoot: localRoot, refreshObserver: viewModel.inputs.refreshObserver, contacts: $0.2, recentBeneficiaries: $0.1)
            }).disposed(by: rx.disposeBag)
        
        return result.asObserver()
    }
}
