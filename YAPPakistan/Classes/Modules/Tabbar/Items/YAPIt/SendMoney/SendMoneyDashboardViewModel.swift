//
//  SendMoneyDashboardViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 04/01/2022.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import YAPComponents

protocol SendMoneyDashboardViewModelInput {
    var closeObserver: AnyObserver<Void> { get }
    var actionObserver: AnyObserver<YapItTileAction> { get }
    var refreshObserver: AnyObserver<Void> { get }
    var searchObserver: AnyObserver<Void> { get }
    var viewDidAppearObserver: AnyObserver<Void> { get }
}

protocol SendMoneyDashboardViewModelOutput {
    var close: Observable<Void> { get }
    var action: Observable<YapItTileAction> { get }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var heading: Observable<String?> { get }
    var recentBeneficiaryViewModel: RecentBeneficiaryViewModelType { get }
    var showsRecentBeneficiary: Observable<Bool> { get }
    var error: Observable<String> { get }
    var y2yFundsTransfer: Observable<YAPContact> { get }
//    var sendMoneyFundsTransfer: Observable<SendMoneyBeneficiary> { get }
//    var allCountries: Observable<[SendMoneyBeneficiaryCountry]> { get }
    var search: Observable<[SearchableBeneficiaryType]> { get }
    var y2yContacts: Observable<[YAPContact]> { get }
    var y2yRecentBeneficiaries: Observable<[Y2YRecentBeneficiary]> { get }
}

protocol SendMoneyDashboardViewModelType {
    var inputs : SendMoneyDashboardViewModelInput { get }
    var outputs: SendMoneyDashboardViewModelOutput { get }
}

class SendMoneyDashboardViewModel: SendMoneyDashboardViewModelType, SendMoneyDashboardViewModelInput, SendMoneyDashboardViewModelOutput {
        
    // MARK: Properties
    var repositories : YapItRepository!
    private var accountProvider: AccountProvider!
    
    var inputs: SendMoneyDashboardViewModelInput { self }
    var outputs: SendMoneyDashboardViewModelOutput { self }
    
    private let disposeBag = DisposeBag()
    private let recentBeneficiariesViewModel = RecentBeneficiaryViewModel()
    private let repository: YapItRepository!
    
    private let closeSubject = PublishSubject<Void>()
    private let actionSubject = PublishSubject<YapItTileAction>()
    private let cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private let headingSubject: BehaviorSubject<String?>
    private let refreshSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    private let y2yFundsTransferSubject = PublishSubject<YAPContact>()
//    private let sendMoneyFundsTransferSubject = PublishSubject<SendMoneyBeneficiary>()
//    private let allCountriesSubject = BehaviorSubject<[SendMoneyBeneficiaryCountry]>(value: [])
    private let searchSubject = PublishSubject<Void>()
    private let viewDidObserverSubject = PublishSubject<Void>()
    private let sendMoneyBeneficiariesSubject = BehaviorSubject<[SendMoneyBeneficiary]>(value: [])
    private let y2yRecentBeneficiariesSubject = BehaviorSubject<[Y2YRecentBeneficiary]>(value: [])
    private let y2yContactsSubject = BehaviorSubject<[YAPContact]>(value: [])
    private let recentBeneficiaries = BehaviorSubject<[RecentBeneficiaryType]>(value: [])
    private let searchableBeneficiaries = BehaviorSubject<[SearchableBeneficiaryType]>(value: [])
    private let contactsManager: ContactsManager
    
    // MARK: - Inputs
    
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    var actionObserver: AnyObserver<YapItTileAction> { actionSubject.asObserver() }
    var refreshObserver: AnyObserver<Void> { refreshSubject.asObserver() }
    var searchObserver: AnyObserver<Void> { searchSubject.asObserver() }
    var viewDidAppearObserver: AnyObserver<Void> { viewDidObserverSubject.asObserver() }
    
    // MARK: - Outputs
    
    var close: Observable<Void> { closeSubject.asObservable() }
    var action: Observable<YapItTileAction> { actionSubject.asObservable() }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var heading: Observable<String?> { headingSubject.asObservable() }
    var showsRecentBeneficiary: Observable<Bool> { recentBeneficiaries.map{ $0.count > 0 }.asObservable() }
    var recentBeneficiaryViewModel: RecentBeneficiaryViewModelType { recentBeneficiariesViewModel }
    var error: Observable<String> { errorSubject.asObservable() }
    var y2yFundsTransfer: Observable<YAPContact> { y2yFundsTransferSubject.asObservable() }
//    var sendMoneyFundsTransfer: Observable<SendMoneyBeneficiary> { sendMoneyFundsTransferSubject.asObservable() }
//    var allCountries: Observable<[SendMoneyBeneficiaryCountry]> { allCountriesSubject.asObservable() }
    var search: Observable<[SearchableBeneficiaryType]> { searchSubject.withLatestFrom(searchableBeneficiaries).asObservable() }
    var y2yContacts: Observable<[YAPContact]> { y2yContactsSubject.asObservable() }
    var y2yRecentBeneficiaries: Observable<[Y2YRecentBeneficiary]> { y2yRecentBeneficiariesSubject.asObservable() }
    
    // MARK: - Initialization
    
    init(_ repository: YapItRepository, contactsManager: ContactsManager, accountProvider: AccountProvider) {
//
        self.repository = repository
        self.contactsManager = contactsManager
        self.accountProvider = accountProvider
        
        headingSubject = BehaviorSubject(value: "Who do you want to send money to?")
        
        let items: [YapItTileAction] = [.yapContact, .bankTransfer, .qrCode]
        let res = items.map { YapItTileCellViewModel($0) }
        cellViewModelsSubject.onNext([SectionModel(model: 0, items: res)])
        
        viewDidObserverSubject.subscribe(onNext: { _ in
//            contactsManager.resetContactManager()
        }).disposed(by: disposeBag)
        
        fetchRecentBeneficiaries(repository)
        
        recentBeneficiaries.bind(to: recentBeneficiariesViewModel.inputs.recentBeneficiaryObserver).disposed(by: disposeBag)
        
        makeRecentBeneficiaries()
        makeSearchableBeneficiaries()
    }
    
}

// MARK: - Beneficiary maneupulation

private extension SendMoneyDashboardViewModel {
    
    func makeRecentBeneficiaries() {
        Observable.combineLatest(sendMoneyBeneficiariesSubject.map{ $0.filter{ $0.lastTranseferDate != nil } }.map{ $0 as [RecentBeneficiaryType] }, y2yRecentBeneficiariesSubject.map{ $0 as [RecentBeneficiaryType] })
            .map{ Array(($0.0 + $0.1).sorted { $0.beneficiaryLasTransferDate > $1.beneficiaryLasTransferDate }.prefix(15)).indexed }
            .bind(to: recentBeneficiaries)
            .disposed(by: disposeBag)
    }
    
    func makeSearchableBeneficiaries() {
        Observable.combineLatest(sendMoneyBeneficiariesSubject.map{ $0 as [SearchableBeneficiaryType] }, y2yContactsSubject.map{ $0.filter{ $0.isYapUser } as [SearchableBeneficiaryType] })
            .map{ ($0.0 + $0.1).sorted{ ($0.searchableTitle ?? "") < ($1.searchableTitle ?? "") }.indexed }
            .bind(to: searchableBeneficiaries)
            .disposed(by: disposeBag)
    }
}

// MARK: - Fetch data

private extension SendMoneyDashboardViewModel {
    func fetchRecentBeneficiaries(_ repository: YapItRepository) {
        
        contactsManager.syncPhoneBookContacts()
        
        let y2yBeneficiariesRequest = refreshSubject.startWith(())
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap{ repository.fetchRecentY2YBeneficiaries() }
            .share()
        
        let sendMoneyBeneficiariesRequest = refreshSubject.startWith(())
            .flatMap{ repository.fetchRecentSendMoneyBeneficiaries() }
            .share()
        
//        let countriesRequest = repository.fetchBeneficiaryCountries().share()
        
        y2yBeneficiariesRequest.map{ _ in }
            .subscribe(onNext: { respons in
                YAPProgressHud.hideProgressHud()
            })
            .disposed(by: disposeBag)
        
        Observable.merge(contactsManager.error, Observable.merge(y2yBeneficiariesRequest.errors(), sendMoneyBeneficiariesRequest.errors()).map{ $0.localizedDescription })
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
        
        sendMoneyBeneficiariesRequest.elements().bind(to: sendMoneyBeneficiariesSubject).disposed(by: disposeBag)
        y2yBeneficiariesRequest.elements().bind(to: y2yRecentBeneficiariesSubject).disposed(by: disposeBag)
//        countriesRequest.elements().bind(to: allCountriesSubject).disposed(by: disposeBag)
        
        Observable.combineLatest(y2yBeneficiariesRequest.elements(),
                                 contactsManager.result,
                                 self.accountProvider.currentAccount.unwrap().map { $0.customer.uuid }.unwrap())
            .map({ (y2yRecents, contactResult, currentAccountUUID) -> [YAPContact] in
                var allContacts: [YAPContact] = contactResult
                allContacts.removeAll { $0.yapAccountDetails?.first?.uuid == currentAccountUUID }
                allContacts.append(contentsOf: y2yRecents.map({ YAPContact.contact(fromRecentBeneficiary: $0) }))
                return allContacts.unique() })
            .bind(to: y2yContactsSubject)
            .disposed(by: disposeBag)
    }
}
