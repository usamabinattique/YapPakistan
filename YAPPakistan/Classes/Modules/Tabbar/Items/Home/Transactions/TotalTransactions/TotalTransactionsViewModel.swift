//
//  TotalTransactionsViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 23/05/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme
import UIKit

protocol TotalTransactionsViewModelInput {
    var backObserver: AnyObserver<Void> { get}
}

protocol TotalTransactionsViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    
    var error: Observable<String> { get }
    var back: Observable<Void> { get }
    var navigationTitle: Observable<String> { get }
    var merchantName: Observable<String> { get }
    var totalAmount: Observable<String> { get }
    
}

protocol TotalTransactionsViewModelType {
    var inputs: TotalTransactionsViewModelInput { get }
    var outputs: TotalTransactionsViewModelOutput { get }
}

class TotalTransactionsViewModel: TotalTransactionsViewModelType, TotalTransactionsViewModelInput, TotalTransactionsViewModelOutput {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TotalTransactionsViewModelInput { return self }
    var outputs: TotalTransactionsViewModelOutput { return self }
    private var themeService: ThemeService<AppTheme>
    private var transactionRepository : TransactionsRepositoryType
    var cellViewModels: [ReusableTableViewCellViewModelType] = [ReusableTableViewCellViewModelType]()
    
    // MARK: Inputs
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() } 
    
    // MARK: - Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var navigationTitle: Observable<String> { return navigationTitleSubject.asObservable()}
    var error: Observable<String> { return errorSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var merchantName: Observable<String> { merchantNameSubject.asObservable() }
    var totalAmount: Observable<String> { totalAmountSubject.asObservable() }
    
    internal var navigationTitleSubject = BehaviorSubject<String>(value: "")
    
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let errorSubject = PublishSubject<String>()
    private let backSubject = PublishSubject<Void>()
    private let merchantNameSubject = BehaviorSubject<String>(value: "") // PublishSubject<String>()
    private let totalAmountSubject = BehaviorSubject<String>(value: "") //PublishSubject<String>()
    
    // MARK: - Init
    init(txnType: String, productCode: String, receiverCustomerId: String?, senderCustomerId: String?, beneficiaryId: String?, merchantName: String?, totalPurchase: String, transactionRepository: TransactionsRepositoryType ,themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        self.transactionRepository = transactionRepository
        
        setNaviagtionTitle(withTransacationsCount: 5)
        self.getTotalTransactions(txnType: txnType, productCode: productCode, receiverCustomerId: receiverCustomerId, senderCustomerId: senderCustomerId, beneficiaryId: nil, merchantName: nil)
        self.merchantNameSubject.onNext("Sent to " + (merchantName ?? "Unknown"))
        self.totalAmountSubject.onNext(totalPurchase)
    }
    
    private func setNaviagtionTitle(withTransacationsCount count : Int) {
        navigationTitleSubject.onNext("\(count) Transactions")
    }
    
    private func getTotalTransactions(txnType: String, productCode: String, receiverCustomerId: String?, senderCustomerId: String?, beneficiaryId: String?, merchantName: String?) {
        YAPProgressHud.showProgressHud()
        let fetchTotalTransactionsRequest = transactionRepository.fetchTotalPurchases(txnType: txnType, productCode: productCode, receiverCustomerId: receiverCustomerId, senderCustomerId: senderCustomerId, beneficiaryId: beneficiaryId, merchantName: merchantName)
        
        fetchTotalTransactionsRequest.elements().subscribe(onNext: { [unowned self] transactions in
            YAPProgressHud.hideProgressHud()
            
            for transaction in transactions {
                self.cellViewModels.append(TransactionTabelViewCellViewModel(transaction: transaction, color: UIColor.gray, themeService: self.themeService))
            }
            setNaviagtionTitle(withTransacationsCount: transactions.count)
            dataSourceSubject.onNext([SectionModel(model: 0, items: cellViewModels)])
            
        }).disposed(by: disposeBag)
        
        fetchTotalTransactionsRequest.errors().subscribe(onNext: { [unowned self] error in
            YAPProgressHud.hideProgressHud()
            errorSubject.onNext(error.localizedDescription)
        }).disposed(by: disposeBag)
    }
}

