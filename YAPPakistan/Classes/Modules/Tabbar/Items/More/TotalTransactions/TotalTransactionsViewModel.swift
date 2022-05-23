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
    
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    
    // MARK: - Init
    init(themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        let cellViewModels: [ReusableTableViewCellViewModelType] = [TransactionTabelViewCellViewModel(transaction: TransactionResponse(), color: UIColor.gray, themeService: themeService),TransactionTabelViewCellViewModel(transaction: TransactionResponse(), color: UIColor.gray, themeService: themeService),TransactionTabelViewCellViewModel(transaction: TransactionResponse(), color: UIColor.gray, themeService: themeService),TransactionTabelViewCellViewModel(transaction: TransactionResponse(), color: UIColor.gray, themeService: themeService),TransactionTabelViewCellViewModel(transaction: TransactionResponse(), color: UIColor.gray, themeService: themeService)]
        dataSourceSubject.onNext([SectionModel(model: 0, items: cellViewModels)])
    }
}

