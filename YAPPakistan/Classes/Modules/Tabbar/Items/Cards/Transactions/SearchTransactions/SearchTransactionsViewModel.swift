//
//  SearchTransactionsViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 19/04/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxDataSources
import RxTheme


protocol SearchTransactionsViewModelInput {
    var searchTextObserver: AnyObserver<String?> { get }
    var closeObserver: AnyObserver<Void> { get }
}

protocol SearchTransactionsViewModelOutput {
    var searchText: Observable<String?> { get }
    var transactionsViewModel: TransactionsViewModelType { get }
    var close: Observable<Void> { get }
    var transactionDetails: Observable<CDTransaction> { get }
    var noTransFound: Observable<String> { get }
}

protocol SearchTransactionsViewModelType {
    var inputs: SearchTransactionsViewModelInput { get }
    var outputs: SearchTransactionsViewModelOutput { get }
}

class SearchTransactionsViewModel: SearchTransactionsViewModelInput, SearchTransactionsViewModelOutput, SearchTransactionsViewModelType {
    
    // MARK: Properties
    
    var inputs: SearchTransactionsViewModelInput { self }
    var outputs: SearchTransactionsViewModelOutput { self }
    private let disposeBag = DisposeBag()
    
    private let searchTextSubject = PublishSubject<String?>()
    private let closeSubject = PublishSubject<Void>()
    private let transactionDetailsSubject = PublishSubject<CDTransaction>()
    private let noTransFoundSubject = ReplaySubject<String>.create(bufferSize: 1)
    
    lazy var transactionsViewModelSubject: TransactionsViewModelType = {
        let transactionViewModel: TransactionsViewModelType = TransactionsViewModel(transactionDataProvider: transactionDataProvider, cardSerialNumber: card?.cardSerialNumber, themService: themeService, showFilter: false)

        return transactionViewModel
    }()
    
    
    
    private let card: PaymentCard?
    
    // MARK: Inputs
    
    var searchTextObserver: AnyObserver<String?> { searchTextSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    
    // MARK: Outpus
    
    var searchText: Observable<String?> { searchTextSubject.asObservable() }
    var transactionsViewModel: TransactionsViewModelType { transactionsViewModelSubject }
    var close: Observable<Void> { closeSubject.asObservable() }
    var transactionDetails: Observable<CDTransaction> { transactionDetailsSubject.asObservable() }
    var noTransFound: Observable<String> { noTransFoundSubject.asObservable() }
    
    private var themeService: ThemeService<AppTheme>!
    private var transactionDataProvider: PaymentCardTransactionProvider!
    
    init(card: PaymentCard? = nil, themeService: ThemeService<AppTheme>!, transactionDataProvider: PaymentCardTransactionProvider) {
        self.card = card
        self.themeService = themeService
        self.transactionDataProvider = transactionDataProvider
        
        searchTextSubject.subscribe(onNext: { text in
            print("search text in searchTranVM \(text)")
        }).disposed(by: disposeBag)
        
        searchTextSubject.bind(to: transactionsViewModelSubject.inputs.searchTextObserver).disposed(by: disposeBag)
        transactionsViewModelSubject.outputs.transactionDetails.bind(to: transactionDetailsSubject).disposed(by: disposeBag)
        
        transactionsViewModelSubject.inputs.fetchTransactionsObserver.onNext(())
    }
    
}
