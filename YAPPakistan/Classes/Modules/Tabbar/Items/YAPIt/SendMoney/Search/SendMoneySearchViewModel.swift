//
//  SendMoneySearchViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 19/01/2022.
//

import Foundation
import RxSwift
import YAPComponents
import RxDataSources

protocol SendMoneySearchViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var cancelObserver: AnyObserver<Void> { get }
    var beneficiaryObserver: AnyObserver<SearchableBeneficiaryType> { get }
    var refreshObserver: AnyObserver<Void> { get }
    var showBlockedOTPErrorObserver: AnyObserver<String> { get }
}

protocol SendMoneySearchViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var beneficiarySelected: Observable<SearchableBeneficiaryType> { get }
    var error: Observable<String>{ get }
    var cancel: Observable<Void> { get }
}

protocol SendMoneySearchViewModelType {
    var inputs: SendMoneySearchViewModelInput { get }
    var outputs: SendMoneySearchViewModelOutput { get }
}

class SendMoneySearchViewModel: SendMoneySearchViewModelType, SendMoneySearchViewModelInput, SendMoneySearchViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SendMoneySearchViewModelInput { return self }
    var outputs: SendMoneySearchViewModelOutput { return self }
    
    private var allBeneficiaries: [SearchableBeneficiaryType] = []
    
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let textSubject = PublishSubject<String?>()
    private let cancelSubject = PublishSubject<Void>()
    private let beneficiarySubject = PublishSubject<SearchableBeneficiaryType>()
    private let cancelPressFromSenedMoneyFundTransferSubject = PublishSubject<Void>()
    
    private let refreshSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    
    // MARK: - Inputs
    var showBlockedOTPErrorObserver: AnyObserver<String>{ errorSubject.asObserver() }
    var textObserver: AnyObserver<String?> { return textSubject.asObserver() }
    var cancelObserver: AnyObserver<Void> { return cancelSubject.asObserver() }
    var beneficiaryObserver: AnyObserver<SearchableBeneficiaryType> { return beneficiarySubject.asObserver() }
    var cancelPressFromSenedMoneyFundTransferObserver: AnyObserver<Void>{ return cancelPressFromSenedMoneyFundTransferSubject.asObserver() }
    var refreshObserver: AnyObserver<Void> { refreshSubject.asObserver() }
    
    // MARK: - Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var beneficiarySelected: Observable<SearchableBeneficiaryType> { return beneficiarySubject.asObservable() }
    var cancelPressFromSenedMoneyFundTransfer: Observable<Void>{ return cancelPressFromSenedMoneyFundTransferSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var cancel: Observable<Void> { cancelSubject.asObservable() }
    
    
    // MARK: - Init
    init(_ beneficiaries: [SearchableBeneficiaryType]) {
        allBeneficiaries = beneficiaries
        
        dataSourceSubject.onNext([SectionModel(model: 0, items: beneficiaries.map { SendMoneySearchCellViewModel(beneficiary: $0) })])
        
        search()
        
        cancelSubject.subscribe(onNext: { [unowned self] in
            self.beneficiarySubject.onCompleted()
        }).disposed(by: disposeBag)
    }
}

// MARK: Search

private extension SendMoneySearchViewModel {
    func search() {
        
        let filtered = textSubject.filter { !($0?.isEmpty ?? true) }.unwrap().map { [unowned self] text -> [SearchableBeneficiaryType] in
            return self.allBeneficiaries.filter { $0.searchableTitle?.lowercased().contains(text.lowercased()) ?? false || ($0.searchableSubTitle?.lowercased().contains(text.lowercased()) ?? false) } }
        
        let unfiltered = textSubject.filter { $0?.isEmpty ?? true }.map { [unowned self] _ in self.allBeneficiaries }
        
        let beneficiaries = Observable.merge(filtered, unfiltered)
        
        let noResults = beneficiaries.filter { $0.count == 0 }.map { _ -> [SectionModel<Int, ReusableTableViewCellViewModelType>] in
            return [SectionModel(model: 0, items: [NoSearchResultCellViewModel()])]
        }
        
        let results = beneficiaries.filter { $0.count > 0 }.map { allBeneficiaries -> [SectionModel<Int, ReusableTableViewCellViewModelType>] in
            return [SectionModel(model: 0, items: allBeneficiaries.map { SendMoneySearchCellViewModel(beneficiary: $0)})]
        }
        
        Observable.merge(results, noResults)
            .bind(to: dataSourceSubject)
            .disposed(by: disposeBag)
    }
}

