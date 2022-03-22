//
//  SMFTAmountInputCellViewModel.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift

protocol SMFTAmountInputCellViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var endEditingObserver: AnyObserver<Void> { get }
    var isValidAmountObserver: AnyObserver<Bool> { get }
    
}

protocol SMFTAmountInputCellViewModelOutput {
    var text: Observable<String?> { get }
    var currency: Observable<String?> { get }
    var completed: Observable<String?> { get }
    var isValidAmount: Observable<Bool> { get }
    var allowedDecimalPlaces: Observable<Int> { get }
}

protocol SMFTAmountInputCellViewModelType {
    var inputs: SMFTAmountInputCellViewModelInput { get }
    var outputs: SMFTAmountInputCellViewModelOutput { get }
}

class SMFTAmountInputCellViewModel: SMFTAmountInputCellViewModelType, SMFTAmountInputCellViewModelInput, SMFTAmountInputCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SMFTAmountInputCellViewModelInput { return self }
    var outputs: SMFTAmountInputCellViewModelOutput { return self }
    var reusableIdentifier: String { return SMFTAmountInputCell.defaultIdentifier }
    
    private let textSubject = BehaviorSubject<String?>(value: nil)
    private let currencySubject = BehaviorSubject<String?>(value: nil)
    private let endEditingSubject = PublishSubject<Void>()
    private let completedSubject = PublishSubject<String?>()
    private let isValidAmountSubject = BehaviorSubject<Bool>(value: true)
    private let allowedDecimalPlacesSubject: BehaviorSubject<Int>
    
    // MARK: - Inputs
    var textObserver: AnyObserver<String?> { return textSubject.asObserver() }
    var endEditingObserver: AnyObserver<Void> { return endEditingSubject.asObserver() }
    var isValidAmountObserver: AnyObserver<Bool> { isValidAmountSubject.asObserver() }
    
    // MARK: - Outputs
    var text: Observable<String?> { return textSubject.asObservable() }
    var currency: Observable<String?> { return currencySubject.asObservable() }
    var completed: Observable<String?> { return completedSubject.asObservable() }
    var isValidAmount: Observable<Bool> { isValidAmountSubject.asObservable() }
    var allowedDecimalPlaces: Observable<Int> { allowedDecimalPlacesSubject.asObservable() }
    
    // MARK: - Init
    init(_ currency: String) {
        allowedDecimalPlacesSubject = BehaviorSubject(value: CurrencyFormatter.decimalPlaces(for: currency))
        
        currencySubject.onNext(currency)
        endEditingSubject.withLatestFrom(textSubject).bind(to: completedSubject).disposed(by: disposeBag)
    }
}
