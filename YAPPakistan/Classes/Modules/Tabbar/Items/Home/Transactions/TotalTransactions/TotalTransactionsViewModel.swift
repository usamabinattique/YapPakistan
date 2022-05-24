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
    
}

protocol TotalTransactionsViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var navigationTitle: Observable<String> { get }
    var error: Observable<String> { get }
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
    
    // MARK: - Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var navigationTitle: Observable<String> { return navigationTitleSubject.asObservable()}
    var error: Observable<String> { return errorSubject.asObservable() }
    
    internal var navigationTitleSubject = BehaviorSubject<String>(value: "")
    
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let errorSubject = PublishSubject<String>()
    
    // MARK: - Init
    init(transactionRepository: TransactionsRepositoryType ,themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        self.transactionRepository = transactionRepository
        //setNaviagtionTitle(withTransacationsCount: cellViewModels.count)
        self.getTotalTransactions()
    }
    
    private func setNaviagtionTitle(withTransacationsCount count : Int) {
        navigationTitleSubject.onNext("\(count) Transactions")
    }
    
    private func getTotalTransactions() {
        YAPProgressHud.showProgressHud()
        let fetchTotalTransactionsRequest = transactionRepository.fetchTotalPurchases(txnType: "", productCode: "", receiverCustomerId: "", senderCustomerId: "", beneficiaryId: "", merchantName: "")
        
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

