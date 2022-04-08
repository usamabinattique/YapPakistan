//
//  SMFTPOPSelectionViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 29/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxDataSources

protocol SMFTPOPSelectionViewModelInput {
    var popSelectedObserver: AnyObserver<TransferReason> { get }
}

protocol SMFTPOPSelectionViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var popSelected: Observable<TransferReason> { get }
    var dismiss: Observable<Void> { get }
    var sectionViewModels: [SMFTPOPCategoryCellViewModel] { get }
}

protocol SMFTPOPSelectionViewModelType {
    var inputs: SMFTPOPSelectionViewModelInput { get }
    var outputs: SMFTPOPSelectionViewModelOutput { get }
}

class SMFTPOPSelectionViewModel: SMFTPOPSelectionViewModelType, SMFTPOPSelectionViewModelInput, SMFTPOPSelectionViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SMFTPOPSelectionViewModelInput { return self }
    var outputs: SMFTPOPSelectionViewModelOutput { return self }
    
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
    init(_ pops: [TransferReason]) {
        
      //  var selectedCategory: TransferReasonCategory? = nil
        var selectedCategory: TransferReason? = nil
        
        sectionViewModelsSubject = pops.map{ SMFTPOPCategoryCellViewModel($0) }
        
        dataSourceSubject.onNext(sectionViewModels.map{ _ in SectionModel(model: 0, items: []) })
        
        let sectionSelected = Observable.merge(sectionViewModelsSubject.map{ $0.outputs.tap }).share()
        
//        Observable.merge(sectionSelected.filter{ !$0.isCategory }.map{ $0 as? TransferReason }.unwrap(), popSelectedObvSubject)
//            .subscribe(onNext: { [weak self] in
//                self?.popSelectedSubject.onNext($0)
//                self?.dismissSubject.onNext(())
//                self?.popSelectedSubject.onCompleted()
//            })
//            .disposed(by: disposeBag)
        
        Observable.merge(sectionSelected, popSelectedObvSubject)
            .subscribe(onNext: { [weak self] in
                self?.popSelectedSubject.onNext($0)
                self?.dismissSubject.onNext(())
                self?.popSelectedSubject.onCompleted()
            })
            .disposed(by: disposeBag)
        
        
      //  let selectedPopCategory = sectionSelected.filter{ $0.isCategory }.map{ $0 as? TransferReasonCategory}.unwrap()
        
        let selectedPopCategory = sectionSelected.share()
        
       /* selectedPopCategory
            .map{ [unowned self] category -> [SectionModel<Int, ReusableTableViewCellViewModelType>] in
                
                let isCurrent = selectedCategory?.title == category.title
                selectedCategory = isCurrent ? nil : category
                
                guard !isCurrent else {
                    return self.sectionViewModels.map{ sectionViewModel in
                        sectionViewModel.inputs.selectionObserver.onNext(false)
                        return SectionModel(model: 0, items: []) }
                }
                
                let sectionedData = self.sectionViewModels.map{ sectionViewModel -> SectionModel<Int, ReusableTableViewCellViewModelType> in
                    
                    guard let secCategory = (sectionViewModel.pop as? TransferReasonCategory) else {
                        return SectionModel(model: 0, items: [])
                    }
                    
                    sectionViewModel.inputs.selectionObserver.onNext(sectionViewModel.pop.title == selectedCategory?.title)
                    
                    return SectionModel(model: 0, items: secCategory.title == category.title ? secCategory.reasons.map{ SMFTPOPCellViewModel($0, isLast: false) } : [])
                }
                
                return sectionedData }
            .bind(to: dataSourceSubject)
            .disposed(by: disposeBag) */
        
        selectedPopCategory
            .map{ [unowned self] category -> [SectionModel<Int, ReusableTableViewCellViewModelType>] in
                
               // let isCurrent = selectedCategory?.title == category.title
                let isCurrent = selectedCategory?.transferReason == category.transferReason
                selectedCategory = isCurrent ? nil : category
                
                guard !isCurrent else {
                    return self.sectionViewModels.map{ sectionViewModel in
                        sectionViewModel.inputs.selectionObserver.onNext(false)
                        return SectionModel(model: 0, items: []) }
                }
                
                let sectionedData = self.sectionViewModels.map{ sectionViewModel -> SectionModel<Int, ReusableTableViewCellViewModelType> in
                    
//                    guard let secCategory = (sectionViewModel.pop as? TransferReasonCategory) else {
//                        return SectionModel(model: 0, items: [])
//                    }
                    let secCategory = (sectionViewModel.pop) 
                   
                   // sectionViewModel.inputs.selectionObserver.onNext(sectionViewModel.pop.title == selectedCategory?.title)
                    sectionViewModel.inputs.selectionObserver.onNext(sectionViewModel.pop.transferReason == selectedCategory?.transferReason)
                    
//                    return SectionModel(model: 0, items: secCategory.title == category.title ? secCategory.reasons.map{ SMFTPOPCellViewModel($0, isLast: false) } : [])
                    return SectionModel(model: 0, items: secCategory?.transferReason == category.transferReason ? pops.map{ SMFTPOPCellViewModel($0, isLast: false) } : [])
                }
                
                return sectionedData }
            .bind(to: dataSourceSubject)
            .disposed(by: disposeBag)
    }
}

