//
//  TransactionReceiptViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 24/05/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme
import UIKit

protocol TransactionReceiptViewModelInput {
    var shareObserver: AnyObserver<UIImage?> { get }
}

protocol TransactionReceiptViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
}

protocol TransactionReceiptViewModelType {
    var inputs: TransactionReceiptViewModelInput { get }
    var outputs: TransactionReceiptViewModelOutput { get }
}

class TransactionReceiptViewModel: TransactionReceiptViewModelType, TransactionReceiptViewModelInput, TransactionReceiptViewModelOutput {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TransactionReceiptViewModelInput { return self }
    var outputs: TransactionReceiptViewModelOutput { return self }
    private var transactionRepository : TransactionsRepositoryType
    private var transaction: TransactionResponse
    
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let shareSubject = PublishSubject<UIImage?>()
    
    // MARK: Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    
    // MARK: Inputs
    var shareObserver: AnyObserver<UIImage?> { return shareSubject.asObserver() }
    
    // MARK: - Init
    init(transactionRepository: TransactionsRepositoryType, transaction: TransactionResponse) {
        self.transactionRepository = transactionRepository //TransactionResponse() as! TransactionsRepositoryType
        self.transaction = transaction //TransactionResponse() //transaction
        let cellViewModels: [ReusableTableViewCellViewModelType] = [TransactionReceiptTableViewCellViewModel(transaction: self.transaction)]
        
        dataSourceSubject.onNext([SectionModel(model: 0, items: cellViewModels)])
        //getReceipt()
    }
    
    private func getReceipt() {
        
        YAPProgressHud.showProgressHud()
        let receiptRequest = transactionRepository.fetchTransactionReceipt(transactionID: "621951752857")
        
        receiptRequest.elements().subscribe(onNext: { data in
            YAPProgressHud.hideProgressHud()
            print(data)
        }).disposed(by: disposeBag)
        
        receiptRequest.errors().subscribe(onNext: { error in
            YAPProgressHud.hideProgressHud()
            print(error.localizedDescription)
        }).disposed(by: disposeBag)
    }
}

