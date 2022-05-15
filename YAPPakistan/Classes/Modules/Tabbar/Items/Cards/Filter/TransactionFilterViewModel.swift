//
//  TransactionFilterViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 22/12/2021.
//

import Foundation
import RxSwift
import RxDataSources
import YAPComponents

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
    let repository: TransactionsRepositoryType
    private var paymentCard: PaymentCard?
    
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
    init(_ filter: TransactionFilter? = nil, repository: TransactionsRepositoryType, isHomeTransactionsSearch:Bool = false) {
        self.filter = filter ?? TransactionFilter()
        self.repository = repository
        
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
        
        
//        clearSubject.map { _ in }
//            .subscribe(onNext: { [unowned self] in
//                self.resultSubject.onNext(nil)
//            })
//            .disposed(by: disposeBag)
        
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
    
    init(_ filter: TransactionFilter? = nil, repository: TransactionsRepositoryType, isHomeTransactions: Bool) {
        self.filter = filter ?? TransactionFilter()
        self.repository = repository
        
        applySubject.map { [unowned self] in self.filter }
            .subscribe(onNext: { [unowned self] in
                self.resultSubject.onNext($0?.getFiltersCount() ?? 0 > 0 ? $0 : nil)
                self.resultSubject.onCompleted()
            })
            .disposed(by: disposeBag)
        
        
        clearSubject.map { _ in }
            .subscribe(onNext: { [unowned self] in
                self.resultSubject.onNext(nil)
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
        
        addHomeViewModels(isHomeSearch: isHomeTransactions)
    }
}

private extension TransactionFilterViewModel {
    
    
    
    func addViewModels() {
        
        TransactionFilterType.allCases(filter: filter).forEach { (transectionType) in
            let transactions = TransactionFilterCheckBoxCellViewModel(transectionType)
                   transactions.outputs.check.subscribe(onNext: { [unowned self] in self.filter.assignValueAcordingToFilterType(type: transectionType, value: $0)  }).disposed(by: disposeBag)
                   viewModels.append(transactions)
            
            let shareClear = clearSubject.share()
            shareClear.map{ _ in false }.bind(to: transactions.inputs.checkObserver).disposed(by: disposeBag)
            
            shareClear.subscribe(onNext: { [unowned self] in
                guard self.filter != nil else { return }
                self.filter.minAmount = 0
                self.filter.maxAmount = 20000.0000
                self.filter.maxAllowedAmount = 20000.0000
            }).disposed(by: disposeBag)

        }
        
        fetchLimit()
        
    }
    
    func addHomeViewModels(isHomeSearch: Bool) {
        
        HomeTransactionFilterType.allCases(filter: filter).forEach { (transectionType) in
            let transactions = TransactionFilterCheckBoxCellViewModel(transectionType)
                   transactions.outputs.check.subscribe(onNext: { [unowned self] in self.filter.assignValueAcordingToFilterType(type: transectionType, value: $0)  }).disposed(by: disposeBag)
                   viewModels.append(transactions)
            
            let shareClear = clearSubject.share()
            shareClear.map{ _ in false }.bind(to: transactions.inputs.checkObserver).disposed(by: disposeBag)
            
            shareClear.subscribe(onNext: { [unowned self] in
                guard self.filter != nil else { return }
//                self.filter.minAmount = 0
//                self.filter.maxAmount = 20000.0000
//                self.filter.maxAllowedAmount = 20000.0000
            }).disposed(by: disposeBag)

        }
        
        fetchLimit(isHomeSearch: isHomeSearch)
        
    }
    
    func loadCells() {
        dataSourceSubject.onNext([SectionModel(model: 0, items: viewModels)])
    }
    
    func fetchLimit(isHomeSearch:Bool = false) {
        
       
        YAPProgressHud.showProgressHud()

        let request = repository.getTransactionLimit().share().do(onNext: { _ in YAPProgressHud.hideProgressHud() })
        let requestShare = request.share()
        
        requestShare.errors().map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)
        requestShare.errors().subscribe(onNext: { [unowned self] error in
            if !isHomeSearch {
                self.addMockSlider()
                self.loadCells()
            }
            
        }).disposed(by: disposeBag)
        
        
        requestShare.elements().subscribe(onNext: { [unowned self] in
            let range = $0.minAmount...$0.maxAmount
         //   self.filter.maxAllowedAmount = $0.maxAmount
            let selectedRange = self.filter.minAmount < 0 || self.filter.maxAmount < 0 ? range : self.filter.minAmount...(self.filter.maxAmount-1)
            if isHomeSearch {
                self.addSlider(range: range, selectedRange: selectedRange,isHomeSearch: isHomeSearch)
            } else {
                self.addSlider(range: range, selectedRange: selectedRange)
            }
            self.filter.minAmount = $0.minAmount
            self.filter.maxAmount = $0.maxAmount
        }).disposed(by: disposeBag)
       
    }
    
    func addMockSlider() {
        if self.filter != nil {
               let range = filter.minAmount...(filter.maxAmount <= 0 ? 20000 : filter.maxAmount)
             //  self.filter.maxAllowedAmount = filter.maxAmount
                self.filter.maxAllowedAmount = filter.maxAmount
               let selectedRange = self.filter.minAmount < 0 || self.filter.maxAmount < 0 ? range : self.filter.minAmount...(self.filter.maxAmount-1)
               self.addSlider(range: range, selectedRange: selectedRange)
           } else {
               let range = 0...20000.0000

               self.filter.maxAllowedAmount = 20000.0000
               let selectedRange = self.filter.minAmount < 0 || self.filter.maxAmount < 0 ? range : self.filter.minAmount...(self.filter.maxAmount > 0 ? (self.filter.maxAmount - 1.0) : 0.0)
               self.addSlider(range: range, selectedRange: selectedRange)
           }
    }
    
    func addSlider(range: ClosedRange<Double>, selectedRange: ClosedRange<Double>,isHomeSearch:Bool = false) {
        if viewModels.last is TransactionFilterSliderCellViewModelType {
            viewModels.removeLast()
        }
        
        let slider: TransactionFilterSliderCellViewModel
        
        if isHomeSearch {
            slider = TransactionFilterSliderCellViewModel(range, selectedRange, isHomeSearch: isHomeSearch)
        } else {
            slider = TransactionFilterSliderCellViewModel(range, selectedRange)
        }
        
        self.viewModels.append(slider)
        
        slider.outputs.selectedRange.subscribe(onNext: { [unowned self] in
            self.filter.minAmount = $0.lowerBound
            self.filter.maxAmount = $0.upperBound
            
        }).disposed(by: self.disposeBag)
        
//        clearSubject.map{ _ in (minValue: CGFloat, maxValue: CGFloat) }.bind(to: slider.inputs.progressObserver).disposed(by: disposeBag)
        
        clearSubject.map { [unowned self] _ -> (minValue: CGFloat, maxValue: CGFloat)  in
            return (minValue: CGFloat(self.filter.minAmount), maxValue: CGFloat(self.filter.maxAmount))
        }.bind(to: slider.inputs.progressObserver, slider.inputs.resetRangeObserver).disposed(by: disposeBag)

        self.loadCells()
    }
    
//    func addCheckboxCells() {
////        self.filter.minAmount = 0.0
////        self.filter.maxAmount = 100.0
//        TransactionFilterType.allCases(filter: filter).forEach { (transectionType) in
//            let transactions = TransactionFilterCheckBoxCellViewModel(transectionType)
//                   transactions.outputs.check.subscribe(onNext: { [unowned self] in self.filter.assignValueAcordingToFilterType(type: transectionType, value: $0)  }).disposed(by: disposeBag)
//                   viewModels.append(transactions)
//            print(viewModels.count)
//            let shareClear = clearSubject.share()
//            shareClear.map{ _ in false }.bind(to: transactions.inputs.checkObserver).disposed(by: disposeBag)
//        }
//    }
}
