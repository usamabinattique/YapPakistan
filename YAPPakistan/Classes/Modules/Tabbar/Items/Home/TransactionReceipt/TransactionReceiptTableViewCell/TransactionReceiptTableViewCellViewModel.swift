//
//  TransactionReceiptTableViewCellViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 24/05/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPComponents

protocol TransactionReceiptTableViewCellViewModelInput {
    
}

protocol TransactionReceiptTableViewCellViewModelOutput {
    var transactionDate: Observable<String> { get }
    var accountNo: Observable<String> { get }
    var amount: Observable<String> { get }
    var refernceNumber: Observable<String> { get }
}

protocol TransactionReceiptTableViewCellViewModelType {
    var inputs: TransactionReceiptTableViewCellViewModelInput { get }
    var outputs: TransactionReceiptTableViewCellViewModelOutput { get }
}

class TransactionReceiptTableViewCellViewModel: TransactionReceiptTableViewCellViewModelType, TransactionReceiptTableViewCellViewModelInput, TransactionReceiptTableViewCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TransactionReceiptTableViewCellViewModelInput { return self }
    var outputs: TransactionReceiptTableViewCellViewModelOutput { return self }
    var reusableIdentifier: String { return TransactionReceiptTableViewCell.defaultIdentifier }
    var transaction: TransactionResponse
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var transactionDate: Observable<String> { return transactionDateSubject.asObservable() }
    var accountNo: Observable<String> { return accountNoSubject.asObservable() }
    var amount: Observable<String> { return amountSubject.asObservable() }
    var refernceNumber: Observable<String> { return referenceNumberSubject.asObservable() }
    
    // MARK: Output Subjects
    var transactionDateSubject = BehaviorSubject<String>(value: "")
    var accountNoSubject = BehaviorSubject<String>(value: "")
    var amountSubject = BehaviorSubject<String>(value: "")
    var referenceNumberSubject = BehaviorSubject<String>(value: "")
    
    // MARK: - Init
    init(transaction: TransactionResponse) {
        self.transaction = transaction
        bind()
    }
    
    private func bind() {
        self.transactionDateSubject.onNext(DateFormatter.transactionNoteUserReadableDateFormatter.string(from: self.transaction.date))
        //self.accountNoSubject.onNext(String(transaction.amount))
        self.amountSubject.onNext(String(CurrencyFormatter.format(amount: transaction.amount, in: .pkr)))
        self.referenceNumberSubject.onNext("asdsadsa")
    }
}
