//
//  TDReceiptsTableViewCellViewModel.swift
//  Cards
//
//  Created by Janbaz Ali on 26/10/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxDataSources

protocol TDReceiptsTableViewCellViewModelInputs {
    var selectedModelObserver: AnyObserver<IndexPath> { get }
    var deleteReceiptObserver: AnyObserver<Int?> { get }
}

protocol TDReceiptsTableViewCellViewModelOutputs {
    var title: Observable<String> { get }
    var descriptionText: Observable<String> { get }
    var isCollectionHidden: Observable<Bool> { get }
    var receiptsDataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var itemSelected: Observable<IndexPath?> { get }
    var deleteReceipt: Observable<Int?> { get }
}

protocol TDReceiptsTableViewCellViewModelType {
    var inputs: TDReceiptsTableViewCellViewModelInputs { get }
    var outputs: TDReceiptsTableViewCellViewModelOutputs { get }
}

class TDReceiptsTableViewCellViewModel: TDReceiptsTableViewCellViewModelType, ReusableTableViewCellViewModelType, TDReceiptsTableViewCellViewModelInputs, TDReceiptsTableViewCellViewModelOutputs {
    
    
    var reusableIdentifier: String { return TDReceiptsTableViewCell.defaultIdentifier }
    
    private let disposeBag = DisposeBag()
    private var cellViewModels: [ReusableCollectionViewCellViewModelType] = []
    var receipts: [String]?
    
    private let receiptsDataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private let titleSubject = BehaviorSubject<String>(value: "")
    private let descriptionSubject = BehaviorSubject<String>(value: "")
    private let isCollectionHiddenSubject = BehaviorSubject<Bool>(value: true)
    private let selectedModelSubject = PublishSubject<IndexPath>()
    private let itemSlectedSubject = PublishSubject<IndexPath?>()
    private let deleteReceiptSubject = PublishSubject<Int?>()
    
    var inputs: TDReceiptsTableViewCellViewModelInputs { return self }
    var outputs: TDReceiptsTableViewCellViewModelOutputs { return self }
    
    // MARK: - Inputs
    var selectedModelObserver: AnyObserver<IndexPath> { return selectedModelSubject.asObserver() }
    var deleteReceiptObserver: AnyObserver<Int?> { deleteReceiptSubject.asObserver() }
    
    // MARK: - Outputs
    var title: Observable<String> { return titleSubject.asObservable() }
    var descriptionText: Observable<String> { return descriptionSubject.asObservable() }
    var isCollectionHidden: Observable<Bool> { return isCollectionHiddenSubject.asObservable() }
    var itemSelected: Observable<IndexPath?> { return itemSlectedSubject.asObservable() }
    var receiptsDataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { return receiptsDataSourceSubject.asObservable() }
    var deleteReceipt: Observable<Int?> { deleteReceiptSubject.asObservable() }
    
    // MARK: - Init
    init(receipts: [String]? = nil) {
        self.receipts = receipts
        
        descriptionSubject.onNext("screen_transaction_details_display_text_add_receipt_description".localized)
        guard let `receipts` = receipts else {
            titleSubject.onNext("screen_transaction_details_display_text_add_receipt".localized)
            isCollectionHiddenSubject.onNext(true)
            return
        }
    
        titleSubject.onNext(receipts.count > 0 ? (receipts.count == 1 ? "\(receipts.count) receipt added" : "\(receipts.count) receipts added") : "screen_transaction_details_display_text_add_receipt".localized)
        isCollectionHiddenSubject.onNext(receipts.count > 0 ? false : true )
        
        generateViewModels(receipts: receipts)
        
        selectedModelSubject.subscribe(onNext: { [unowned self] index in
            self.itemSlectedSubject.onNext(index)
            }).disposed(by: disposeBag)
    }
    
    func generateViewModels(receipts: [String]) {
    
        for (index,_) in receipts.enumerated() {
            let vm = TDReceiptCollectionViewCellViewModel(title:"Receipt \(index + 1)",receiptIndex: index)
            vm.outputs.deleteReceipt.bind(to: inputs.deleteReceiptObserver).disposed(by: disposeBag)
            cellViewModels.append(vm)
        }
        
        receiptsDataSourceSubject.onNext([SectionModel(model: 0, items: cellViewModels)])
        
    }
}





