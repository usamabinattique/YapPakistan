//
//  TransactionFilterViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 22/12/2021.
//

import Foundation
import RxSwift
import RxDataSources

public protocol TransactionFilterViewModelInput {
    var applyObserver: AnyObserver<Void> { get }
    var clearObserver: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<Void> { get }
}

public protocol TransactionFilterViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var result: Observable<TransactionFilter?> { get }
    var error: Observable<String> { get }
    var close: Observable<Void> { get }

}

public protocol TransactionFilterViewModelType {
    var inputs: TransactionFilterViewModelInput { get }
    var outputs: TransactionFilterViewModelOutput { get }
}

public class TransactionFilterViewModel: TransactionFilterViewModelType, TransactionFilterViewModelInput, TransactionFilterViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    public var inputs: TransactionFilterViewModelInput { return self }
    public var outputs: TransactionFilterViewModelOutput { return self }
    private var filter: TransactionFilter!
    private var viewModels = [ReusableTableViewCellViewModelType]()
//    private let repository = TransactionsRepository()
    
    private let applySubject = PublishSubject<Void>()
    private let clearSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    private let resultSubject = PublishSubject<TransactionFilter?>()
    private let errorSubject = PublishSubject<String>()
    
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    
    // MARK: - Inputs
    public var applyObserver: AnyObserver<Void> { return applySubject.asObserver() }
    public var clearObserver: AnyObserver<Void> { return clearSubject.asObserver() }
    public var closeObserver: AnyObserver<Void> { return closeSubject.asObserver() }
    
    // MARK: - Outputs
    public var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    public var result: Observable<TransactionFilter?> { return resultSubject.asObservable() }
    public var error: Observable<String> { return errorSubject.asObservable() }
    public var close: Observable<Void> { closeSubject.asObservable() }
    
    // MARK: - Init
    public init(_ filter: TransactionFilter? = nil) {
        self.filter = filter ?? TransactionFilter()
        
        applySubject.map { [unowned self] in self.filter }
            .subscribe(onNext: { [unowned self] in
                self.resultSubject.onNext($0?.getFiltersCount() ?? 0 > 0 ? $0 : nil)
                self.resultSubject.onCompleted()

                //                var params = [String: Any]()
                //                if let categoriesArr = $0?.categories.prefix(5) {
                //
                //                    params = categoriesArr.reduce(into: [:], { result, next in
                //                        result["category\(result.count)"] = next.rawValue
                //                    })
                //                }
                //                params ["incoming"] = $0?.creditSearch
                //                params ["outgoing"] = $0?.debitSearch
                //                params ["value_from"] = $0?.minAmount
                //                params ["value_to"] = $0?.maxAmount
                //                params ["value_currency"] = "AED"
                //                AppAnalytics.shared.logEvent(DashboardEvent.applyFilter(params))
                
            })
            .disposed(by: disposeBag)
        
        closeSubject
            .filter{ [unowned self] in self.filter.getFiltersCount() > 0 }
            .subscribe(onNext: { [weak self] _ in self?.resultSubject.onCompleted() }).disposed(by: disposeBag)
        
        closeSubject
            .filter{ [unowned self] in self.filter.getFiltersCount() <= 0 }
            .map{ _ in }
            .bind(to: applySubject)
            .disposed(by: disposeBag)
        
        addViewModels()
    }
}

private extension TransactionFilterViewModel {
    func addViewModels() {
        
        TransactionFilterType.allCases(filter: filter).forEach { (transectionType) in
            let transactions = TransactionFilterCheckBoxCellViewModel(transectionType)
                   transactions.outputs.check.subscribe(onNext: { [unowned self] in self.filter.assignValueAcordingToFilterType(type: transectionType, value: $0)  }).disposed(by: disposeBag)
                   viewModels.append(transactions)

            clearSubject.map{ _ in false }.bind(to: transactions.inputs.checkObserver).disposed(by: disposeBag)
        }
        
        fetchLimit()

        loadCells()
    }
    
    func loadCells() {
        dataSourceSubject.onNext([SectionModel(model: 0, items: viewModels)])
    }
    
    func fetchLimit() {
//        YAPProgressHud.showProgressHud()
//
//        let request = repository.getTransactionLimit().share().do(onNext: { _ in YAPProgressHud.hideProgressHud() })
//
//        request.errors().map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)
//
//        request.elements().subscribe(onNext: { [unowned self] in
//            let range = $0.minAmount...$0.maxAmount
//            self.filter.maxAllowedAmount = $0.maxAmount
//            let selectedRange = self.filter.minAmount < 0 || self.filter.maxAmount < 0 ? range : self.filter.minAmount...self.filter.maxAmount
//            self.addSlider(range: range, selectedRange: selectedRange)
//        }).disposed(by: disposeBag)
        
        self.addSlider(range: 0...1000, selectedRange: 0...100)
    }
    
    func addSlider(range: ClosedRange<Double>, selectedRange: ClosedRange<Double>) {
        if viewModels.last is TransactionFilterSliderCellViewModelType {
            viewModels.removeLast()
        }
        
        let slider = TransactionFilterSliderCellViewModel(range, selectedRange)
        self.viewModels.append(slider)
        
        slider.outputs.selectedRange.subscribe(onNext: { [unowned self] in
            self.filter.minAmount = $0.lowerBound
            self.filter.maxAmount = $0.upperBound
            
        }).disposed(by: self.disposeBag)
        
        clearSubject.map{ _ in 1.0 }.bind(to: slider.inputs.progressObserver).disposed(by: disposeBag)
        
        //            self.loadCells()
    }
}
