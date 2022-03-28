//
//  BankListSearchViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 16/03/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxDataSources

protocol BankListSearchViewModelInputs {
    var textObserver: AnyObserver<String?> { get }
    var cancelObserver: AnyObserver<Void> { get }
    var cellSelected: AnyObserver<BankDetail> { get }
}

protocol BankListSearchViewModelOutputs {
    var billerText: Observable<String?> { get }
    var showError: Observable<String> { get }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var bank: Observable<BankDetail> { get }
}

protocol BankListSearchViewModelType {
    var inputs: BankListSearchViewModelInputs { get }
    var outputs: BankListSearchViewModelOutputs { get }
}

class BankListSearchViewModel: BankListSearchViewModelType, BankListSearchViewModelInputs, BankListSearchViewModelOutputs {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var banks: [BankDetail]
    private let cellSelectedSubject = PublishSubject<BankDetail>()
    var inputs: BankListSearchViewModelInputs { return self }
    var outputs: BankListSearchViewModelOutputs { return self }
    
    private let textSubject = PublishSubject<String?>()
    private let cancelSubject = PublishSubject<Void>()
    private let billerTextSubject = BehaviorSubject<String?>(value: nil)
    private let showErrorSubject = PublishSubject<String>()
    private let currentSelected = BehaviorSubject<Int>(value: 0)
    private let banksSubject = ReplaySubject<[BankDetail]>.create(bufferSize: 1)
    private let errorsSubject = PublishSubject<String>()
    private var resultSubject = [ReusableTableViewCellViewModelType]()
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    
    
    // MARK: - Inputs
    
    var textObserver: AnyObserver<String?> { return textSubject.asObserver() }
    var cancelObserver: AnyObserver<Void> { return cancelSubject.asObserver() }
    var cellSelected: AnyObserver<BankDetail> { return cellSelectedSubject.asObserver() }
    
    // MARK: - Outputs
    
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var billerText: Observable<String?> { return billerTextSubject.asObservable() }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var bank: Observable<BankDetail> { cellSelectedSubject.asObservable() }
    
    // MARK: - Init
    init(_ banks: [BankDetail]) {
        
        self.banks = banks
        banksSubject.onNext(banks)
        banksSubject
            .map { $0.map {AddBeneficiaryCellViewModel($0) } }
            .map { [SectionModel(model: 0, items: $0)] }
            .bind(to: dataSourceSubject).disposed(by: disposeBag)
        search()
    }
}

private extension BankListSearchViewModel {
    func search() {
       let result =  Observable.combineLatest(textSubject.unwrap().map { $0.trimmingCharacters(in: .whitespacesAndNewlines ) }, banksSubject)
            .map { text, allBanks in
                allBanks.filter {
                    guard !text.isEmpty else { return true }
                    return $0.bankName.lowercased().contains(text.lowercased())
                }
            }
            .map { $0.map {AddBeneficiaryCellViewModel($0) } }.share()
        result.map { viewModels  -> [SectionModel<Int, ReusableTableViewCellViewModelType>]  in
            if viewModels.count == 0 {
                return [SectionModel(model: 0, items: [NoSearchResultCellViewModel()])]
            } else {
                return [SectionModel(model: 0, items: viewModels)]
            }
        }.bind(to: dataSourceSubject).disposed(by: disposeBag)
    }
}
