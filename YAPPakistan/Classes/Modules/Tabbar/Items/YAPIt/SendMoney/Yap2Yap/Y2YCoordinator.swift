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
        
        viewModel.outputs.search.unwrap().subscribe(onNext: { [weak self] in
            self?.searchContacts($0)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.invteFriend.subscribe(onNext: { [weak self] in
            self?.inviteFriend($0.0, self?.name ?? "", appShareUrl: $0.1)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.invite.subscribe(onNext: { [weak self] in
           // AppAnalytics.shared.logEvent(Y2YEvent.inviteTapped())
            self?.inviteFriends( self?.name ?? "", appShareUrl: $0)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.contactSelected.subscribe(onNext: { [unowned self] in
            self.sendMoney($0)
        }).disposed(by: rx.disposeBag)
        
        return result
    }
    
}

private extension Y2YCoordinator {

    func searchContacts(_ contacts: [YAPContact]) {
        let viewModel = Y2YSearchViewModel(contacts)
        let viewController = Y2YSearchViewController(viewModel: viewModel, themeService: self.container.themeService)
        root.pushViewController(viewController, animated: true)

        viewModel.outputs.invite.subscribe(onNext: { [weak self] in
            self?.inviteFriend($0.0, self?.name ?? "", appShareUrl: $0.1)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.contactSelected.subscribe(onNext: { [weak self] in
            self?.sendMoney($0)
        }).disposed(by: rx.disposeBag)
    }
    
    func sendMoney(_ contact: YAPContact) {

        coordinate(to: Y2YFundsTransferCoordinator(root: root, container: container, contact: contact, repository: repository)).subscribe(onNext: { [weak self] in
            if case let ResultType.success(result) = $0 {
                self?.result.onNext(.success(result))
                self?.result.onCompleted()
            }
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: Invite friend

private extension Y2YCoordinator {
    func inviteFriends( _ name: String, appShareUrl: String) {
        let account = container.accountProvider.currentAccountValue.value
        inviteFriendRepository.saveReferralInvite(customerId: account?.customer.customerId ?? "").asSingle().subscribe().disposed(by: rx.disposeBag)
        let activityViewController = UIActivityViewController(activityItems: [appShareMessageForY2Y(welcomeMessage: "\n\n\(account?.customer.firstName ?? "")", appShareUrl: appShareUrl)], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = root.view
        root.present(activityViewController, animated: true, completion: nil)
    }

    func inviteFriend(_ contact: YAPContact, _ name: String, appShareUrl: String) {
        let account = container.accountProvider.currentAccountValue.value
        inviteFriendRepository.saveReferralInvite(customerId: account?.customer.customerId ?? "").asSingle().subscribe().disposed(by: rx.disposeBag)
        let activityViewController = UIActivityViewController(activityItems: [appShareMessageForY2Y(welcomeMessage: "\n\n\(account?.customer.firstName ?? "")", appShareUrl: appShareUrl)], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = root.view
        root.present(activityViewController, animated: true, completion: nil)
    }
}

extension Y2YCoordinator: MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension Y2YCoordinator: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
}
