//
//  TDReceiptCollectionViewCellViewModel.swift
//  Cards
//
//  Created by Janbaz Ali on 26/10/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents

protocol TDReceiptCollectionViewCellViewModelInputs {
    var deleteReceiptObserver: AnyObserver<Void> { get }
}

protocol TDReceiptCollectionViewCellViewModelOutputs {
    var title: Observable<String> { get }
    var deleteReceipt: Observable<Int?> { get }
}

protocol TDReceiptCollectionViewCellViewModelType {
    var inputs: TDReceiptCollectionViewCellViewModelInputs { get }
    var outputs: TDReceiptCollectionViewCellViewModelOutputs { get }
}

class TDReceiptCollectionViewCellViewModel: TDReceiptCollectionViewCellViewModelType, TDReceiptCollectionViewCellViewModelInputs, TDReceiptCollectionViewCellViewModelOutputs, ReusableCollectionViewCellViewModelType {
    
    let disposeBag = DisposeBag()
    var reusableIdentifier: String { return TDReceiptCollectionViewCell.defaultIdentifier }
    
    var inputs: TDReceiptCollectionViewCellViewModelInputs { return self}
    var outputs: TDReceiptCollectionViewCellViewModelOutputs { return self }
    
    private let titleSubject = BehaviorSubject<String>(value: "")
    private let deleteReceiptSubject = PublishSubject<Void>()
    
    // MARK: - inputs
    var deleteReceiptObserver: AnyObserver<Void> { deleteReceiptSubject.asObserver() }
    
    // MARK: - outputs
    var title: Observable<String> { titleSubject.asObservable() }
    var deleteReceipt: Observable<Int?> { deleteReceiptSubject.map{ [unowned self] _ in self.receiptIndex  } }
    
    private var receiptIndex: Int?
    
    init(title: String, receiptIndex: Int?) {
        self.receiptIndex = receiptIndex
        titleSubject.onNext(title)
    }
}
