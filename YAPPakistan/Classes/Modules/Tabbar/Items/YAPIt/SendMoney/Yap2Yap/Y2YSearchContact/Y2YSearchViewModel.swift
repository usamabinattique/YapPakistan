//
//  Y2YSearchViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 17/01/2022.
//

import Foundation


import Foundation
import RxSwift
import RxDataSources
import YAPCore

protocol Y2YSearchViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var cancelObserver: AnyObserver<Void> { get }
    var contactObserver: AnyObserver<YAPContact> { get }
    var yapContactObserver: AnyObserver<Void> { get }
    var allContactObserver: AnyObserver<Void> { get }
}

protocol Y2YSearchViewModelOutput {
    var contactSelected: Observable<YAPContact> { get }
    var invite: Observable<(YAPContact, String)> { get }
    var contactText: Observable<String?> { get }
    var showError: Observable<String> { get }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
}

protocol Y2YSearchViewModelType {
    var inputs: Y2YSearchViewModelInput { get }
    var outputs: Y2YSearchViewModelOutput { get }
}

class Y2YSearchViewModel: Y2YSearchViewModelType, Y2YSearchViewModelInput, Y2YSearchViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: Y2YSearchViewModelInput { return self }
    var outputs: Y2YSearchViewModelOutput { return self }
    var contacts =  [Y2YContactCellViewModel]()
    
    private let contactSelectedSubject = PublishSubject<YAPContact>()
    
    private let textSubject = PublishSubject<String?>()
    private let cancelSubject = PublishSubject<Void>()
    private let contactSubject = PublishSubject<YAPContact>()
    private let yapContactSubject = PublishSubject<Void>()
    private let allContactSubject = PublishSubject<Void>()
    private let inviteSubject = PublishSubject<(YAPContact, String)>()
    private let contactTextSubject = BehaviorSubject<String?>(value: nil)
    private let showErrorSubject = PublishSubject<String>()
    private let currentSelected = BehaviorSubject<Int>(value: 0)
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    
    private var currentContactModels = [ReusableTableViewCellViewModelType]()
    private let refreshDataSubject = PublishSubject<Void>()
    
    // MARK: - Inputs
    var textObserver: AnyObserver<String?> { return textSubject.asObserver() }
    var cancelObserver: AnyObserver<Void> { return cancelSubject.asObserver() }
    var contactObserver: AnyObserver<YAPContact> { return contactSubject.asObserver() }
    var yapContactObserver: AnyObserver<Void> { return yapContactSubject.asObserver() }
    var allContactObserver: AnyObserver<Void> { return allContactSubject.asObserver() }
    
    // MARK: - Outputs
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var contactSelected: Observable<YAPContact> { return contactSelectedSubject.asObservable() }
    var contactText: Observable<String?> { return contactTextSubject.asObservable() }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObserver() }
    var invite: Observable<(YAPContact, String)> { return inviteSubject.asObservable() }
    
    private let referralManager: AppReferralManager
    
    // MARK: - Init
    init(_ contacts: [YAPContact], accountProvider: AccountProvider, referralManager: AppReferralManager) {
        
        self.referralManager = referralManager
        
        self.contacts = contacts.map {
            [unowned self] in
            let viewModel = Y2YContactCellViewModel($0)
            
            let currentAccount = accountProvider.currentAccount
            let appRefMessage = currentAccount.map{ $0?.customer.customerId }.unwrap().map{ self.referralManager.pkReferralURL(forInviter: $0)}
            let obs = Observable.just($0)
            let comb = Observable.combineLatest(obs,appRefMessage)
            viewModel.outputs.invite.withLatestFrom(comb).bind(to: self.inviteSubject).disposed(by: disposeBag)
            
            return viewModel
        }
        
        dataSourceSubject.onNext([SectionModel(model: 0,
                                               items:contacts
                                                .map({Y2YContactCellViewModel($0)})
                                              )])
        
        yapContactSubject.map { 0 }.bind(to: currentSelected).disposed(by: disposeBag)
        allContactSubject.map { 1 }.bind(to: currentSelected).disposed(by: disposeBag)
        
        search()
        
        contactSubject.filter {
            $0.isYapUser
        }.bind(to: contactSelectedSubject).disposed(by: disposeBag)
        
        cancelSubject.subscribe(onNext: { [weak self] in
            self?.contactSelectedSubject.onCompleted()
            self?.inviteSubject.onCompleted()
        }).disposed(by: disposeBag)
        
    }
}

private extension Y2YSearchViewModel {
    func search() {
        Observable.combineLatest(textSubject.unwrap().map { $0.trimmingCharacters(in: .whitespacesAndNewlines ) }, currentSelected)
            .subscribe(onNext: { [unowned self] text, currentTab in
                let filtered = self.contacts.filter {
                    let lowerText = text.lowercased()
                    let phoneText = text.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "^0", with: "", options: .regularExpression).replacingOccurrences(of: "^\\+", with: "00", options: .regularExpression)
                    
                    return (text.count > 0 ? ($0.contact.name.lowercased().contains(lowerText) || ($0.contact.fullPhoneNumber.contains(phoneText) || phoneText.isEmpty)) : true) && ((currentTab == 1 && !$0.contact.isYapUser) || (currentTab == 0 && $0.contact.isYapUser))
                }
                
                self.currentContactModels = filtered
                if self.currentContactModels.count == 0 {
                    self.currentContactModels.append(NoSearchResultCellViewModel())
                }
                self.refreshDataSubject.onNext(())
                self.contactTextSubject.onNext(currentTab == 1 || filtered.count == 0 ? nil : String.init(format: filtered.count == 1 ? "screen_y2y_display_text_yap_contact".localized : "screen_y2y_display_text_yap_contacts".localized, filtered.count))
                let filteredList = filtered.map({ contactObj -> SectionModel<Int, ReusableTableViewCellViewModelType> in
                    return SectionModel(model: 0, items: [contactObj])
                })
                dataSourceSubject.onNext(filteredList)
            })
            .disposed(by: disposeBag)
    }
}
