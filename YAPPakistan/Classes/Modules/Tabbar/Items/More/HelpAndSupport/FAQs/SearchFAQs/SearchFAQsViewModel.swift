//
//  SearchFAQsViewModel.swift
//  Adjust
//
//  Created by Awais on 18/05/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPComponents

protocol SearchFAQsViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var cancelObserver: AnyObserver<Void> { get }
    var beneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { get }
    var cancelPressFromSenedMoneyFundTransferObserver: AnyObserver<Void>{ get}
    var editBeneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { get }
    var deleteBeneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { get }
    var refreshObserver: AnyObserver<Void> { get }
    var showBlockedOTPErrorObserver: AnyObserver<String> { get }
}

protocol SearchFAQsViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var beneficiarySelected: Observable<SendMoneyBeneficiary> { get }
    var cancelPressFromSenedMoneyFundTransfer: Observable<Void>{ get }
    var editBeneficiary: Observable<SendMoneyBeneficiary> { get }
    var error: Observable<String>{ get }
    var cancel: Observable<Void>{ get }
}

protocol SearchFAQsViewModelType {
    var inputs: SearchFAQsViewModelInput { get }
    var outputs: SearchFAQsViewModelOutput { get }
}

class SearchFAQsViewModel: SearchFAQsViewModelType, SearchFAQsViewModelInput, SearchFAQsViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SearchFAQsViewModelInput { return self }
    var outputs: SearchFAQsViewModelOutput { return self }
    
    private var allBeneficiaries: [SendMoneyBeneficiary] = []
    
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let textSubject = PublishSubject<String?>()
    private let cancelSubject = PublishSubject<Void>()
    private let beneficiarySubject = PublishSubject<SendMoneyBeneficiary>()
    private let cancelPressFromSenedMoneyFundTransferSubject = PublishSubject<Void>()
    
    private let editBeneficiarySubject = PublishSubject<SendMoneyBeneficiary>()
    private let deleteBeneficiarySubject = PublishSubject<SendMoneyBeneficiary>()
    private let refreshSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    
    // MARK: - Inputs
    var showBlockedOTPErrorObserver: AnyObserver<String>{ errorSubject.asObserver() }
    var textObserver: AnyObserver<String?> { return textSubject.asObserver() }
    var cancelObserver: AnyObserver<Void> { return cancelSubject.asObserver() }
    var beneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { return beneficiarySubject.asObserver() }
    var cancelPressFromSenedMoneyFundTransferObserver: AnyObserver<Void>{ return cancelPressFromSenedMoneyFundTransferSubject.asObserver() }
    var editBeneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { return editBeneficiarySubject.asObserver() }
    var deleteBeneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { return deleteBeneficiarySubject.asObserver() }
    var refreshObserver: AnyObserver<Void> { refreshSubject.asObserver() }
    
    // MARK: - Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var beneficiarySelected: Observable<SendMoneyBeneficiary> { return beneficiarySubject.asObservable() }
    var cancelPressFromSenedMoneyFundTransfer: Observable<Void>{ return cancelPressFromSenedMoneyFundTransferSubject.asObservable() }
    var editBeneficiary: Observable<SendMoneyBeneficiary> { return editBeneficiarySubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var cancel: Observable<Void> { cancelSubject.asObservable() }
    
    private var faqs = [FAQsResponse]()
    
    // MARK: - Init
    init(faqs: [FAQsResponse]) {
        
        self.faqs = faqs
//        dataSourceSubject.onNext([SectionModel(model: 0, items: beneficiaries.map { SendMoneyHomeBeneficiaryCellViewModel($0) })])

//        search()
//        refresh()

        
    }
}

// MARK: Search

private extension SearchFAQsViewModel {
    func search() {
        
//        let filtered = textSubject.filter { !($0?.isEmpty ?? true) }.unwrap().map { [unowned self] text -> [SendMoneyBeneficiary] in
//            return self.allBeneficiaries.filter { $0.accountTitle.lowercased().contains(text.lowercased()) || ($0.nickName?.lowercased().contains(text.lowercased()) ?? false) } }
//
//        let unfiltered = textSubject.filter { $0?.isEmpty ?? true }.map { [unowned self] _ in self.allBeneficiaries }
//
//        let beneficiaries = Observable.merge(filtered, unfiltered)
//
//        let noResults = beneficiaries.filter { $0.count == 0 }.map { _ -> [SectionModel<Int, ReusableTableViewCellViewModelType>] in
//            return [SectionModel(model: 0, items: [NoSearchResultCellViewModel()])]
//        }
//
//        let results = beneficiaries.filter { $0.count > 0 }.map { allBeneficiaries -> [SectionModel<Int, ReusableTableViewCellViewModelType>] in
//            return [SectionModel(model: 0, items: allBeneficiaries.map { SendMoneyHomeBeneficiaryCellViewModel($0)})]
//        }
//
//        Observable.merge(results, noResults)
//            .bind(to: dataSourceSubject)
//            .disposed(by: disposeBag)
    }
}

// MARK: Refresh beneficiary list

private extension SearchFAQsViewModel {
    func refresh() {
//        let refreshRequest = refreshSubject
//            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
//            .flatMap{ [unowned self] _ in self.repository.fetchAllIBFTBeneficiaries() }
//            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
//            .share()
//
//        refreshRequest.errors()
//            .map{ $0.localizedDescription }
//            .bind(to: errorSubject)
//            .disposed(by: disposeBag)
//
//        refreshRequest.elements()
//            .map { $0.enumerated().map { SendMoneyBeneficiary($0.1, index: $0.0) } }
//            .do(onNext: { [weak self] in self?.allBeneficiaries = $0 })
//            .withLatestFrom(textSubject)
//            .bind(to: textSubject)
//            .disposed(by: disposeBag)
    }
}

