//
//  Y2YViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 10/01/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxDataSources
import Contacts
import PhoneNumberKit


protocol Y2YViewModelInput {
    var searchObserver: AnyObserver<Void> { get }
    var yapContactObserver: AnyObserver<Void> { get }
    var allContactObserver: AnyObserver<Void> { get }
    var inviteObserver: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<Void> { get }
    var refreshObserver: AnyObserver<Void> { get }
    var contactSelectedObserver: AnyObserver<YAPContact> { get }
    func cellSelected(at indexPath: IndexPath)
}

protocol Y2YViewModelOutput {
//    var invite: Observable<String> { get }
    var search: Observable<[YAPContact]?> { get }
    
    var recentContactsAvailable: Observable<Bool> { get }
    var allContactsAvailable: Observable<Bool> { get }
    var showError: Observable<String> { get }
    var sendMoney: Observable<Contact> { get }
    var showActivity: Observable<Bool> { get }
    var close: Observable<Void> { get }
    var headerText: Observable<NSAttributedString> { get }
    var invteFriend: Observable<(YAPContact, String)> { get }
    var contactSelected: Observable<YAPContact> { get }
    var noContactTitle: Observable<String?> { get }
    var showsInviteButton: Observable<Bool> { get }
    
    var numberOfCells: Int { get }
    func model(forIndex indexPath: IndexPath) -> Y2YContactCellViewModelType
    var refreshData: Observable<Void> { get }
    var recentBeneficiaryViewModel: RecentBeneficiaryViewModelType { get }
    var isPresented: Bool { get}
    var enableSearch: Observable<Bool> { get }
}

protocol Y2YViewModelType {
    var inputs: Y2YViewModelInput { get }
    var outputs: Y2YViewModelOutput { get }
}

class Y2YViewModel: Y2YViewModelType, Y2YViewModelInput, Y2YViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: Y2YViewModelInput { return self }
    var outputs: Y2YViewModelOutput { return self }
    
    private let repository: Y2YRepositoryType
    private let recentBeneficiariesViewModel = RecentBeneficiaryViewModel()
    
    private let searchSubject = PublishSubject<Void>()
    private let yapContactSubject = PublishSubject<Void>()
    private let allContactSubject = PublishSubject<Void>()
    private let inviteSubject = PublishSubject<Void>()
    
    private let allContactsAvailableSubject = BehaviorSubject<Bool>(value: false)
    
    private let sendMoneySubject = PublishSubject<Contact>()
    private let showActivitySubject = BehaviorSubject<Bool>(value: false)
    private let showErrorSubject = PublishSubject<String>()
    
    private let closeSubject = PublishSubject<Void>()
    private let refreshSubject = BehaviorSubject<Void>(value: ())
    private let headerTextSubject = BehaviorSubject<NSAttributedString>(value: NSAttributedString(string: String.init(format: "screen_y2y_display_text_yap_contacts".localized, 0)))
    
    private let currentSelected = BehaviorSubject<Int>(value: 0)
    private var allContacts: [Contact]!
    private let contactResults = BehaviorSubject<[YAPContact]?>(value: nil)
    
    private let inviteFriendSubject = PublishSubject<(YAPContact, String)>()
    private let contactSelectedSubject = PublishSubject<YAPContact>()
    
    private var yapContactModels = [Y2YContactCellViewModel]()
    private var allContactModels = [Y2YContactCellViewModel]()
    private var currentContactModels = [Y2YContactCellViewModel]()
    private let refreshDataSubject = PublishSubject<Void>()
    private let recentBeneficiariesSubject: BehaviorSubject<[RecentBeneficiaryType]>
    private let enableSearchSubject = BehaviorSubject<Bool>(value: false)
    
    var numberOfCells: Int { return currentContactModels.count }
    private let isPresentedSubject: Bool
    
    private var currentAccount: Observable<Account?>!
    
    // MARK: - Inputs
    var searchObserver: AnyObserver<Void> { return searchSubject.asObserver() }
    var yapContactObserver: AnyObserver<Void> { return yapContactSubject.asObserver() }
    var allContactObserver: AnyObserver<Void> { return allContactSubject.asObserver() }
    var inviteObserver: AnyObserver<Void> { return inviteSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { return closeSubject.asObserver() }
    var refreshObserver: AnyObserver<Void> { return refreshSubject.asObserver() }
    var contactSelectedObserver: AnyObserver<YAPContact> { return contactSelectedSubject.asObserver() }
    
    func cellSelected(at indexPath: IndexPath) {
        let model = currentContactModels[indexPath.row]
        guard model.contact.isYapUser && !model.isShimmering else { return }
        contactSelectedObserver.onNext(YAPContact(name: model.contact.name, phoneNumber: model.contact.phoneNumber, countryCode: model.contact.countryCode, email: model.contact.email, isYapUser: model.contact.isYapUser, photoUrl: model.contact.photoUrl, yapAccountDetails: model.contact.yapAccountDetails, thumbnailData: model.contact.thumbnailData, index: indexPath.row))
    }
    
    // MARK: - Outputs
    var invite: Observable<String> { return inviteSubject.withLatestFrom(currentAccount.map{ $0?.customer.customerId }.unwrap().map{ AppReferralManager(environment: .qa).pkReferralURL(forInviter: $0)}).asObservable() }
    var search: Observable<[YAPContact]?> { return searchSubject.withLatestFrom(contactResults) }
    var recentContactsAvailable: Observable<Bool> { return recentBeneficiariesSubject.map{ $0.count > 0 }.asObservable() }
    var allContactsAvailable: Observable<Bool> { return allContactsAvailableSubject.asObservable() }
    var sendMoney: Observable<Contact> { return sendMoneySubject.asObservable() }
    var showActivity: Observable<Bool> { return showActivitySubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var close: Observable<Void> { return closeSubject.asObservable() }
    var headerText: Observable<NSAttributedString> { return headerTextSubject.asObservable() }
    var invteFriend: Observable<(YAPContact, String)> { return inviteFriendSubject.asObservable() }
    var contactSelected: Observable<YAPContact> { return contactSelectedSubject.asObservable() }
    var refreshData: Observable<Void> { return refreshDataSubject.asObservable() }
    var noContactTitle: Observable<String?> { return currentSelected.map { $0 == 0 ? "screen_y2y_display_text_no_yap_contacts".localized : "screen_y2y_display_text_invite_no_phone_contacts".localized}}
    var showsInviteButton: Observable<Bool> { return currentSelected.map { $0 == 0 } }
    var recentBeneficiaryViewModel: RecentBeneficiaryViewModelType { recentBeneficiariesViewModel }
    var isPresented: Bool { isPresentedSubject }
    var enableSearch: Observable<Bool> { enableSearchSubject.asObservable() }
    
    func model(forIndex indexPath: IndexPath) -> Y2YContactCellViewModelType {
        return currentContactModels[indexPath.row]
    }
    
    private let contactsManager: ContactsManager
    
    // MARK: Init
    
    init(repository: Y2YRepositoryType, contacts: [YAPContact] = [], recentBeneficiaries: [Y2YRecentBeneficiary] = [], presented: Bool, contactsManager: ContactsManager, currentAccount: Observable<Account?>) {
        
        self.repository = repository
        self.recentBeneficiariesSubject = BehaviorSubject(value: recentBeneficiaries)
        self.contactsManager = contactsManager
        self.isPresentedSubject = presented
        self.contactResults.onNext(contacts)
        self.currentAccount = currentAccount
        
        showLoadingEffects()
        self.refreshDataSubject.onNext(())
        
        yapContactSubject.subscribe(onNext: { [unowned self] in
            self.currentSelected.onNext(0)
            self.currentContactModels = self.yapContactModels
            self.refreshDataSubject.onNext(())
            self.allContactsAvailableSubject.onNext(self.currentContactModels.count > 0)
            
            let text = String.init(format: self.currentContactModels.count == 1 ? "screen_y2y_display_text_yap_contact".localized : "screen_y2y_display_text_yap_contacts".localized, self.currentContactModels.count)
            let attributed = NSMutableAttributedString(string: text)
//            attributed.addAttributes([.foregroundColor: UIColor.primaryDark], range: NSRange(location: 0, length: text.count))
            attributed.addAttributes([.font: UIFont.small], range: NSRange(location: 0, length: text.count))
            self.headerTextSubject.onNext(attributed)
        }).disposed(by: disposeBag)
        
        allContactSubject.subscribe(onNext: { [unowned self] in
            self.currentSelected.onNext(1)
            self.currentContactModels = self.allContactModels
            self.refreshDataSubject.onNext(())
            self.allContactsAvailableSubject.onNext(self.allContactModels.count > 0)
            
            let text = "screen_y2y_display_text_invite_phone_contacts".localized
            let attributed = NSMutableAttributedString(string: text)
//            attributed.addAttributes([.foregroundColor: UIColor.greyDark], range: NSRange(location: 0, length: text.count))
            attributed.addAttributes([.font: UIFont.micro], range: NSRange(location: 0, length: text.count))
            self.headerTextSubject.onNext(attributed)
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(contactResults.unwrap(), contactsManager.syncProgress)
            .map { (contacts, progress) -> (Bool, [YAPContact]) in
                (progress >= 1.0, contacts) }
            .subscribe(onNext: { [unowned self] (value, filteredContacts) in
                if value {
                    let allViewModels = filteredContacts.map { [unowned self] contact -> Y2YContactCellViewModel in
                        let viewModel = Y2YContactCellViewModel(contact)
                       // viewModel.outputs.invite.bind(to: self.inviteFriendSubject).disposed(by: self.disposeBag)
                      
                        let a = currentAccount.map{ $0?.customer.customerId }.unwrap().map{ AppReferralManager(environment: .qa).pkReferralURL(forInviter: $0)}
                        let obs = Observable.just(contact)
                        let comb = Observable.combineLatest(obs,a)
                        viewModel.outputs.invite.withLatestFrom(comb).bind(to: self.inviteFriendSubject).disposed(by: disposeBag)
                        return viewModel }
                    self.allContactModels = allViewModels
                    self.yapContactModels = allViewModels.filter { $0.contact.isYapUser }
                    guard  let currentIndex = try? self.currentSelected.value() else {
                        self.yapContactSubject.onNext(())
                        return
                    }
                    if currentIndex == 0 {
                        self.yapContactSubject.onNext(())
                    } else {
                        self.allContactSubject.onNext(())
                    }
                }
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(contactResults.unwrap(), contactsManager.error)
            .subscribe(onNext: { [unowned self] (filteredContacts, _) in
                let allViewModels = filteredContacts.map { [unowned self] contact -> Y2YContactCellViewModel in
                    let viewModel = Y2YContactCellViewModel(contact)
//                    viewModel.outputs.invite.bind(to: self.inviteFriendSubject).disposed(by: self.disposeBag)
                    

                    let a = currentAccount.map{ $0?.customer.customerId }.unwrap().map{ AppReferralManager(environment: .qa).pkReferralURL(forInviter: $0)}
                    let obs = Observable.just(contact)
                    let comb = Observable.combineLatest(obs,a)
                    viewModel.outputs.invite.withLatestFrom(comb).bind(to: self.inviteFriendSubject).disposed(by: disposeBag)
                    
                    return viewModel }
                self.allContactModels = allViewModels
                self.yapContactModels = allViewModels.filter { $0.contact.isYapUser }
                guard  let currentIndex = try? self.currentSelected.value() else {
                    self.yapContactSubject.onNext(())
                    return
                }
                if currentIndex == 0 {
                    self.yapContactSubject.onNext(())
                } else {
                    self.allContactSubject.onNext(())
                }
            }).disposed(by: disposeBag)
        
        DispatchQueue.main.async {
            contactsManager.syncPhoneBookContacts()
        }
        contactsManager.isSyncing.bind(to: showActivitySubject).disposed(by: disposeBag)
        contactsManager.isSyncing.map { !$0 }.bind(to: enableSearchSubject).disposed(by: disposeBag)
        
        Observable.combineLatest(contactsManager.result, recentBeneficiariesSubject, currentAccount.unwrap().map { $0.uuid })
            .map{ contacts, recents, currentAccountUUID -> [YAPContact] in
                var allContacts = contacts
                allContacts.removeAll { $0.yapAccountDetails?.first?.uuid == currentAccountUUID }
                allContacts.append(contentsOf: recents.map({ YAPContact.contact(fromRecentBeneficiary: $0 as! Y2YRecentBeneficiary) }))
                return allContacts.sorted { $0.name < $1.name  } }
            .bind(to: contactResults)
            .disposed(by: disposeBag)
        
        contactsManager.error.bind(to: showErrorSubject).disposed(by: disposeBag)
        Observable.merge(contactsManager.error.map{ _ in  0 }, contactsManager.result.map{ _ in 0 }).bind(to: currentSelected).disposed(by: disposeBag)
        fetchRecentBeneficiaries()
        
        recentBeneficiariesSubject.bind(to: recentBeneficiariesViewModel.inputs.recentBeneficiaryObserver).disposed(by: disposeBag)
        
        recentBeneficiariesTransfers()
    }
}

// MARK: Requests

private extension Y2YViewModel {
    
    func fetchRecentBeneficiaries() {
        
        var color: Int = 0
        
        let recentBeneficiariesRequest = refreshSubject.flatMap { [unowned self] in self.repository.fetchRecentY2YBeneficiaries() }.share()
        
        recentBeneficiariesRequest.errors().map { $0.localizedDescription }.bind(to: showErrorSubject).disposed(by: disposeBag)
        
        let elemenets = recentBeneficiariesRequest.elements()
            .map {
                $0.map { beneficiary -> RecentBeneficiaryType in
                    color += 1
                    
                    let recentBeneficiary = Y2YRecentBeneficiary(name: beneficiary.name, phoneNumber: beneficiary.phoneNumber, photoUrl: beneficiary.photoUrl, uuid: beneficiary.uuid, accountType: beneficiary.accountType, index: color, lastTranseferDate: beneficiary.lastTranseferDate, countryCode: beneficiary.countryCode)
                                                                 //, firstName: beneficiary.firstName, lastName: beneficiary.lastName)
                    return recentBeneficiary
                }
        }
        
        elemenets.bind(to: recentBeneficiariesSubject).disposed(by: disposeBag)
    }
    
    func recentBeneficiariesTransfers() {
        let recentBeneficiary =  recentBeneficiariesViewModel.outputs.itemSelected
            .withLatestFrom(Observable.combineLatest(recentBeneficiariesViewModel.outputs.itemSelected, recentBeneficiariesSubject))
            .map{ $0.1[$0.0] }
            .share(replay: 1, scope: .whileConnected)
        
        recentBeneficiary.map{ $0 as? Y2YRecentBeneficiary }.unwrap()
            .map{ YAPContact.contact(fromRecentBeneficiary: $0) }
            .bind(to: contactSelectedSubject)
            .disposed(by: disposeBag)
    }
}

// MARK: - Shimmer data

private extension Y2YViewModel {
    func showLoadingEffects() {
        var dummyObjects: [Y2YContactCellViewModel] = []
        for _ in 1...12 {
            dummyObjects.append(Y2YContactCellViewModel())
        }
        currentContactModels = dummyObjects
        allContactModels = dummyObjects
        self.allContactsAvailableSubject.onNext(self.currentContactModels.count > 0)
    }
}
