//
//  Y2YCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 10/01/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import MessageUI

public class Y2YCoordinator: Coordinator<ResultType<Void>> {
    private var root: UINavigationController
    private let result = PublishSubject<ResultType<Void>>()
    private let refreshContacts = PublishSubject<Void>()
    private var name: String?
    private let repository: Y2YRepositoryType
    private let contacts: [YAPContact]
    private let recentBeneficiaries: [Y2YRecentBeneficiary]
    private let inviteFriendRepository: InviteFriendRepositoryType
    private let presentable: Bool
    private var container: UserSessionContainer!
    let contactsManager: ContactsManager
    
    public init(root: UINavigationController,
                container: UserSessionContainer,
                repository: Y2YRepositoryType,
                contacts: [YAPContact] = [],
                recentBeneficiaries: [Y2YRecentBeneficiary] = [],
                inviteFriendRepository: InviteFriendRepositoryType,
                presentable: Bool = false,
                contactsManager: ContactsManager
    ) {
        self.root = root
        self.repository = repository
        self.contacts = contacts
        self.recentBeneficiaries = recentBeneficiaries
        self.inviteFriendRepository = inviteFriendRepository
        self.presentable = presentable
        self.container = container
        self.contactsManager = contactsManager
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = Y2YViewModel(repository: repository, contacts: contacts, recentBeneficiaries: recentBeneficiaries, presented: presentable, contactsManager: contactsManager, currentAccount: container.accountProvider.currentAccount)
        let viewController = Y2YViewController(themeService: container.themeService, viewModel: viewModel, recentBeneficiaryView: container.makeRecentBeneficiaryView())

//        SessionManager.current.currentAccount.map { $0?.customer.firstName }.subscribe(onNext: { [weak self] in self?.name = $0}).dispose()
        if !presentable {
            self.root.pushViewController(viewController, animated: true)
        } else {
            let navRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
            self.root.present(navRoot, animated: true, completion: nil)
            self.root = navRoot
        }
        
        viewModel.outputs.close.subscribe(onNext: { [weak self] in
            if self?.presentable ?? false {
                self?.root.dismiss(animated: true, completion: nil)
            } else {
                self?.root.popViewController(animated: true)
            }
            self?.result.onNext(ResultType.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
//        self.container.accountProvider.currentAccount.unwrap().map { $0.customer.customerId }.unwrap().subscribe(onNext: { [weak self] customerId in
//            self?.inviteFriendRepository.
//        }).disposed(by: rx.disposeBag)
        return result
    }
    
}
