//
//  LimitTransactionCellViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 14/05/2022.
//

import Foundation
import YAPComponents
import YAPCore
import RxSwift
import RxCocoa

protocol LimitTransactionCellViewModelInput {
    
}

protocol LimitTransactionCellViewModelOutput {
    var transactionTitle: Observable<String> { get }
    var limitProgress: Observable<CGFloat> { get }
    var limitConsumedValue: Observable<String> { get }
    var limitAllocatedValue: Observable<String> { get }
    var isLast: Observable<Bool> { get }
}

protocol LimitTransactionCellViewModelType {
    var inputs: LimitTransactionCellViewModelInput { get }
    var outputs: LimitTransactionCellViewModelOutput { get }
}

class LimitTransactionCellViewModel: LimitTransactionCellViewModelType, LimitTransactionCellViewModelInput, LimitTransactionCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    var reusableIdentifier: String  { LimitTransactionCell.defaultIdentifier }
    public var isLastElement = false
    
    // MARK: - Subjects
    fileprivate let transactionTitleSubject = BehaviorSubject<String>(value: "")
    fileprivate let limitProgressSubject = BehaviorSubject<CGFloat>(value: 0.0)
    fileprivate let limitConsumedValueSubject = BehaviorSubject<String>(value: "")
    fileprivate let limitAllocatedValueSubject = BehaviorSubject<String>(value: "")
    
    // Inputs
    

    // Outputs
    var transactionTitle: Observable<String> { transactionTitleSubject.asObservable() }
    var limitProgress: Observable<CGFloat> { limitProgressSubject.asObservable() }
    var limitConsumedValue: Observable<String> { limitConsumedValueSubject.asObservable() }
    var limitAllocatedValue: Observable<String> { limitAllocatedValueSubject.asObservable() }
    var isLast: Observable<Bool> { Observable.just(isLastElement).asObservable() }

    var inputs: LimitTransactionCellViewModelInput { self }
    var outputs: LimitTransactionCellViewModelOutput { self }

    // Properties
    private let disposeBag = DisposeBag()

    init(_ limitDetail: TransactionLimitsDetail) {
        transactionTitleSubject.onNext(limitDetail.title)
        limitConsumedValueSubject.onNext(String(limitDetail.consumedLimit))
        limitAllocatedValueSubject.onNext(String(limitDetail.allocatedLimit))
        print(isLastElement)
        let progress = CGFloat(limitDetail.consumedLimit)/CGFloat(limitDetail.allocatedLimit)
        limitProgressSubject.onNext(progress)
        
        
    }
}
