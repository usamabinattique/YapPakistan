//
//  CreditLimitPopSelectionViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 31/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxDataSources

protocol CreditLimitPopSelectionViewModelInput {
    var popSelectedObserver: AnyObserver<TransferReason> { get }
}

protocol CreditLimitPopSelectionViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var popSelected: Observable<TransferReason> { get }
    var dismiss: Observable<Void> { get }
    var sectionViewModels: [SMFTPOPCategoryCellViewModel] { get }
}

protocol CreditLimitPopSelectionViewModelType {
    var inputs: CreditLimitPopSelectionViewModelInput { get }
    var outputs: CreditLimitPopSelectionViewModelOutput { get }
}

class CreditLimitPopSelectionViewModel: CreditLimitPopSelectionViewModelType, CreditLimitPopSelectionViewModelInput, CreditLimitPopSelectionViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: CreditLimitPopSelectionViewModelInput { return self }
    var outputs: CreditLimitPopSelectionViewModelOutput { return self }
    
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let popSelectedSubject = PublishSubject<TransferReason>()
    private let popSelectedObvSubject = PublishSubject<TransferReason>()
    private let dismissSubject = PublishSubject<Void>()
    private let sectionViewModelsSubject: [SMFTPOPCategoryCellViewModel]
    
    // MARK: - Inputs
    var popSelectedObserver: AnyObserver<TransferReason> { popSelectedObvSubject.asObserver() }
    
    // MARK: - Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { dataSourceSubject.asObservable() }
    var popSelected: Observable<TransferReason> { popSelectedSubject.asObservable() }
    var dismiss: Observable<Void> { dismissSubject.asObservable() }
    var sectionViewModels: [SMFTPOPCategoryCellViewModel] { sectionViewModelsSubject }
    
    // MARK: - Init
    init() {
        let pops =  [TransferReason]()
        sectionViewModelsSubject = pops.map{ SMFTPOPCategoryCellViewModel($0) }
        
       // dataSourceSubject.onNext(sectionViewModels.map{ _ in SectionModel(model: 0, items: []) })
//        Observable.merge(sectionSelected, popSelectedObvSubject)
//            .subscribe(onNext: { [weak self] in
//                self?.popSelectedSubject.onNext($0)
//                self?.dismissSubject.onNext(())
//                self?.popSelectedSubject.onCompleted()
//            })
//            .disposed(by: disposeBag)
        
        let vm = CreditLimitBottomSheetCellViewModel()
        vm.outputs.gotIt.subscribe(onNext: { [weak self] in
            //self?.popSelectedSubject.onNext($0)
            self?.dismissSubject.onNext(())
//            self?.popSelectedSubject.onCompleted()
        })
        .disposed(by: disposeBag)
        
        dataSourceSubject.onNext([SectionModel(model: 0, items:  [vm])])
            
    }
}
