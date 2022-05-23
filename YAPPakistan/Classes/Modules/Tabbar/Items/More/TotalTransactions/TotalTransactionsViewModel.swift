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
    
    // MARK: - Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var navigationTitle: Observable<String> { return navigationTitleSubject.asObservable()}
    
    internal var navigationTitleSubject = BehaviorSubject<String>(value: "")
    
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    
    // MARK: - Init
    init(themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        let cellViewModels: [ReusableTableViewCellViewModelType] = [TransactionTabelViewCellViewModel(transaction: TransactionResponse(), color: UIColor.gray, themeService: themeService),TransactionTabelViewCellViewModel(transaction: TransactionResponse(), color: UIColor.gray, themeService: themeService),TransactionTabelViewCellViewModel(transaction: TransactionResponse(), color: UIColor.gray, themeService: themeService),TransactionTabelViewCellViewModel(transaction: TransactionResponse(), color: UIColor.gray, themeService: themeService),TransactionTabelViewCellViewModel(transaction: TransactionResponse(), color: UIColor.gray, themeService: themeService)]
        dataSourceSubject.onNext([SectionModel(model: 0, items: cellViewModels)])
        
        setNaviagtionTitle(withTransacationsCount: cellViewModels.count)
    }
    
    private func setNaviagtionTitle(withTransacationsCount count : Int) {
        navigationTitleSubject.onNext("\(count) Transactions")
    }
}

