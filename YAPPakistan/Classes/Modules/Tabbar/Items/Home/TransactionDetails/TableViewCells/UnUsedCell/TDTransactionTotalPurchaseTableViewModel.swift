//
//  TDTransactionTotalPurchaseTableViewModel.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 14/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents

class TDTransactionTotalPurchaseTableViewModel: ReusableTableViewCellViewModelType {
    
    let disposeBag = DisposeBag()
    
    var reusableIdentifier: String { return TDTransactionTotalPurchaseTableViewCell.defaultIdentifier }
    
    private let purchaseCountSubject: BehaviorSubject<Int?>
    private let averageAmountSubject: BehaviorSubject<Double?>
    private let totalAmountSubject: BehaviorSubject<Double?>
    
    // MARK: - inputs
    
    // MARK: - outputs
    var purchaseCount: Observable<Int?> { return purchaseCountSubject.asObservable() }
    var averageAmount: Observable<Double?> { return averageAmountSubject.asObservable() }
    var totalAmount: Observable<Double?> { return totalAmountSubject.asObservable() }
    
    init(totalPurchaseCount: Int, avgAmount: Double, totalAmount: Double) {
        
        purchaseCountSubject = BehaviorSubject(value: totalPurchaseCount)
        averageAmountSubject = BehaviorSubject(value: avgAmount)
        totalAmountSubject = BehaviorSubject(value: totalAmount)
    }
    
}
