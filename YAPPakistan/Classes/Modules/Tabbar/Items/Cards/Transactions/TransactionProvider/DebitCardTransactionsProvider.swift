//
//  DebitCardTransactionsProvider.swift
//  YAP
//
//  Created by Wajahat Hassan on 21/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
// swiftlint:disable line_length
// swiftlint:disable identifier_name

import Foundation
import RxSwift
/// import YAPKit
/// import Networking
/// import Authentication

class DebitCardTransactionsProvider: PaymentCardTransactionProvider {
    
    // MARK: - Properties
    private var repository: TransactionsRepository
    private var transactionsSubject: BehaviorSubject<[TransactionResponse]>
    private let _pageSize: Int
    private var currentPage: Int
    var filter: TransactionFilter? {
        didSet {
            currentPage = 0
        }
    }
    private let disposeBag = DisposeBag()
    public var cardSerialNumber: String?
    private var isFetching: Bool = false
    private var debitSearch: Bool = false
    
    var transactions: Observable<[TransactionResponse]> { return transactionsSubject }
        
    // MARK: - Init
    init(transactionFilter: TransactionFilter? = nil, repository: TransactionsRepository, cardSerialNumber: String? = nil, debitSearch: Bool = false ) {
        self.debitSearch = debitSearch
        self.repository = repository
        self.transactionsSubject = BehaviorSubject(value: [])
        self._pageSize =  200
        self.currentPage = 0
        self.filter = transactionFilter
        self.cardSerialNumber = cardSerialNumber
    }
    
    // MARK: - Methods
    func fetchTransactions() -> Observable<Event<PagableResponse<TransactionResponse>>> {
        guard !isFetching else { return Observable.never() }
        
        isFetching = true
        let request =  cardSerialNumber == nil ? repository.fetchTransactions(pageNumber: currentPage, pageSize: pageSize, minAmount: filter?.minAmount, maxAmount: filter?.maxAmount, creditSearch: filter?.creditSearch, debitSearch: filter?.debitSearch, yapYoungTransfer: filter?.yapYoungTransfer).share() :
        repository.fetchCardTransactions(pageNo: currentPage, pageSize: pageSize, cardSerialNo: cardSerialNumber!, debitSearch: debitSearch,filter: filter).share()

        return request.do(onNext: { [unowned self] response in
            guard response.element != nil else { return }
//            self.currentPage = !pagableResponse.isLast ? self.currentPage + 1 : 0
            
            
            self.isFetching = false
        })
        
      /*  return request.do(onNext: { [unowned self] response in
          //  guard response.element != nil else { return }
//            self.currentPage = !pagableResponse.isLast ? self.currentPage + 1 : 0
            
            
            self.isFetching = false
        }) */
    }
    
    func resetPage(_ page: Int) {
        currentPage = page
    }
    
    func resetCardSerialNumber(serialNumber: String) {
        cardSerialNumber = "?C8F92RQ6XQ34EYQ" //serialNumber
    }
    
    var pageSize: Int { return _pageSize }
    
}
