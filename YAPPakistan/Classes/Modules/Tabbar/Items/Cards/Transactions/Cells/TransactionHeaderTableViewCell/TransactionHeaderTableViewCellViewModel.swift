//
//  TransactionHeaderTableViewCellViewModel.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 28/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

public protocol TransactionHeaderTableViewCellViewModelInputs {
    
}

public protocol TransactionHeaderTableViewCellViewModelOutputs {
    var date: Observable<String?> { get }
    var totalTransactionAmount: Observable<String?> { get }
    var shimmering: Observable<Bool> { get }
}

public protocol TransactionHeaderTableViewCellViewModelType {
    var inputs: TransactionHeaderTableViewCellViewModelInputs { get }
    var outputs: TransactionHeaderTableViewCellViewModelOutputs { get }
}

class TransactionHeaderTableViewCellViewModel: TransactionHeaderTableViewCellViewModelType,
                                               TransactionHeaderTableViewCellViewModelInputs,
                                               TransactionHeaderTableViewCellViewModelOutputs,
                                               ReusableTableViewCellViewModelType {
    
    let disposeBag = DisposeBag()
    var inputs: TransactionHeaderTableViewCellViewModelInputs { return self}
    var outputs: TransactionHeaderTableViewCellViewModelOutputs { return self }
    var reusableIdentifier: String { return TransactionHeaderTableViewCell.defaultIdentifier }
    
    private let dateSubject: BehaviorSubject<String?>
    private let totalTransactionAmountSubject: BehaviorSubject<String?>
    
    // MARK: - inputs
    
    // MARK: - output
    var date: Observable<String?> { return dateSubject.asObservable() }
    var totalTransactionAmount: Observable<String?> { return totalTransactionAmountSubject.asObservable() }
    var shimmering: Observable<Bool> { shimmeringSubject.asObservable() }
    
    private let shimmeringSubject: BehaviorSubject<Bool>
    let isShimmering: Bool
    
    
    init(date: String, totalTransactionsAmount: String) {
        dateSubject = BehaviorSubject(value: date)
        totalTransactionAmountSubject = BehaviorSubject(value: totalTransactionsAmount)
        shimmeringSubject = BehaviorSubject(value: false)
        self.isShimmering = false
    }
    
    init() {
        dateSubject = BehaviorSubject(value: "ajfdkfkdjfdkfdk")
        totalTransactionAmountSubject = BehaviorSubject(value: "asdfdfdffdfdf")
        shimmeringSubject = BehaviorSubject(value: true)
        isShimmering = true
    }
    
}
