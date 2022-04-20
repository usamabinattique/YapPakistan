//
// TransactionsViewModel.swift
// YAP
//
// Created by Wajahat Hassan on 27/08/2019.
// Copyright © 2019 YAP. All rights reserved.
//
// swiftlint:disable line_length
// swiftlint:disable identifier_name

import Foundation
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import GLKit
// import Networking
// import CoreData
// import AppDatabase

protocol TransactionsViewModelInputs {
    var fetchTransactionsObserver: AnyObserver<Void> { get }
    var viewAppearedObsever: AnyObserver<Void> { get }
    var transactionDetailsObserver: AnyObserver<CDTransaction> { get }
    var openFilterObserver: AnyObserver<Void> { get }
    var filterSelected: AnyObserver<TransactionFilter?> { get }
    var openWelcomeTutorialObserver: AnyObserver<Void> { get }
    var searchTextObserver: AnyObserver<String?> { get }
    var showShimmeringObserver: AnyObserver<Bool> { get }
}

protocol TransactionsViewModelOutputs {
    var transactionTableViewCellViewModel: Observable<[SectionModel<(date: String, amount: String), ReusableTableViewCellViewModelType>]> { get }
    var transactions: Observable<[SectionTransaction]> { get }
    var fetchTransactions: Observable<Void> { get }
    var transactionDetails: Observable<CDTransaction> { get }
    var openFilter: Observable<TransactionFilter?> { get }
    var filterEnabled: Observable<Bool> { get }
    var filterCount: Observable<Int> { get }
    var showsPlaceholder: Observable<Bool> { get }
    var showsNothingLabel: Observable<Bool> { get }
    var openWelcomTutorial: Observable<Void> { get }
    
    var reloadData: Observable<Void> { get }
    func sectionViewModel(for section: Int) -> TransactionHeaderTableViewCellViewModelType
    func cellViewModel(for indexPath: IndexPath) -> ReusableTableViewCellViewModelType
    var numberOfSections: Int { get }
    func numberOfRows(inSection section: Int) -> Int
    var showsGraph: Observable<Bool> { get }
    var loading: Observable<Bool> { get }
    var nothingLabelText: Observable<String?> { get }
    var showsFilter: Observable<Bool> { get }
    var showShimmering: Observable<Bool> { get }
}

protocol TransactionsViewModelType {
    var inputs: TransactionsViewModelInputs { get }
    var outputs: TransactionsViewModelOutputs { get }
}

class TransactionsViewModel: NSObject, TransactionsViewModelType, TransactionsViewModelInputs, TransactionsViewModelOutputs {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TransactionsViewModelInputs { return self }
    var outputs: TransactionsViewModelOutputs { return self }
    private var dataProvider: DebitCardTransactionsProvider?

    private let transactionTableViewCellViewModelSubject = BehaviorSubject<[SectionModel<(date: String, amount: String), ReusableTableViewCellViewModelType>]>(value: [])
    private let fetchTransactionsSubject = PublishSubject<Void>()
    private let transactionSubject = BehaviorSubject<[SectionTransaction]>(value: [])
    private let showsPlaceholderSubject = BehaviorSubject<Bool>(value: true)
    private let viewAppearedSubject = PublishSubject<Void>()
    private let isLast = BehaviorSubject<Bool>(value: false)
    private let transactionDetailsSubject = PublishSubject<CDTransaction>()
    private let openFilterSubject = PublishSubject<Void>()
    private let filterSelectedSubject = PublishSubject<TransactionFilter?>()
    private let filterEnabledSubject = BehaviorSubject<Bool>(value: false)
    private let filterCountSubject = BehaviorSubject<Int>(value: 0)
    private var sectionViewModels = [TransactionHeaderTableViewCellViewModel]()
    private var cellViewModels = [[TransactionsTableViewCellViewModel]]()
    private var showsNothingLabelSubject = BehaviorSubject<Bool>(value: false)
    private let reloadDataSubject = PublishSubject<Void>()
    private let openWelcomTutorialSubject = PublishSubject<Void>()
    private let showsGraphSubject = BehaviorSubject(value: false)
    private let loadingSubject = BehaviorSubject<Bool>(value: false)
    private let searchTextSubject = PublishSubject<String?>()
    private let nothingLabelSubject: BehaviorSubject<String?>
    private let showsFilterSubject: BehaviorSubject<Bool>
    private let showShimmeringSubject = ReplaySubject<Bool>.create(bufferSize: 1)

    // MARK: - Input
    var fetchTransactionsObserver: AnyObserver<Void> { return fetchTransactionsSubject.asObserver() }
    var viewAppearedObsever: AnyObserver<Void> { return viewAppearedSubject.asObserver() }
    var transactionDetailsObserver: AnyObserver<CDTransaction> { return transactionDetailsSubject.asObserver() }
    var openWelcomeTutorialObserver: AnyObserver<Void> { openWelcomTutorialSubject.asObserver() }

    var openFilterObserver: AnyObserver<Void> { return openFilterSubject.asObserver() }
    var filterSelected: AnyObserver<TransactionFilter?> { return filterSelectedSubject.asObserver() }
    var searchTextObserver: AnyObserver<String?> { searchTextSubject.asObserver() }
    var showShimmeringObserver: AnyObserver<Bool> { showShimmeringSubject.asObserver() }

    // MARK: - Output
    var fetchTransactions: Observable<Void> { return fetchTransactionsSubject.asObservable() }
    var transactionTableViewCellViewModel: Observable<[SectionModel<(date: String, amount: String), ReusableTableViewCellViewModelType>]> { return transactionTableViewCellViewModelSubject.asObservable() }
    var transactionDetails: Observable<CDTransaction> { return transactionDetailsSubject.asObservable() }
    var openFilter: Observable<TransactionFilter?> { return  openFilterSubject.map { [weak self] in self?.filter } }
    var filterEnabled: Observable<Bool> { return filterEnabledSubject.asObservable() }
    var reloadData: Observable<Void> { return reloadDataSubject.asObservable() }
    var showsPlaceholder: Observable<Bool> { return showsPlaceholderSubject.asObservable() }
    var filterCount: Observable<Int> { return filterCountSubject.asObservable() }
    var transactions: Observable<[SectionTransaction]> { return transactionSubject.asObservable() }
    var showsNothingLabel: Observable<Bool> { showsNothingLabelSubject.asObservable() }
    var openWelcomTutorial: Observable<Void> { openWelcomTutorialSubject.asObservable() }
    var showsGraph: Observable<Bool> { showsGraphSubject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var nothingLabelText: Observable<String?> { nothingLabelSubject.asObservable() }
    var showsFilter: Observable<Bool> { showsFilterSubject.asObservable() }
    var showShimmering: Observable<Bool> { showShimmeringSubject.asObservable() }
    
    func sectionViewModel(for section: Int) -> TransactionHeaderTableViewCellViewModelType {

        let transactions =  [CDTransaction]() //entityHandler.transactions(for: section)
        let amount = 0.0 //transactions.reduce(0, { $1.transactionType == .debit ? $0 - $1.calculatedTotalAmount : $0 + $1.calculatedTotalAmount })
        let date = transactions.first?.transactionDay ?? Date().startOfDay

        return TransactionHeaderTableViewCellViewModel(date: date.transactionSectionReadableDate, totalTransactionsAmount: (amount < 0 ? "- " : "+ ") +  CurrencyFormatter.formatAmountInLocalCurrency(abs(amount)))
    }

    func cellViewModel(for indexPath: IndexPath) -> ReusableTableViewCellViewModelType {

      /*  if let transaction = entityHandler.transaction(for: indexPath) {
            return TransactionsTableViewCellViewModel(transaction: transaction)
        }

        return TransactionsTableViewCellViewModel() */
        
//        var transactionCellViewModels = [TransactionsTableViewCellViewModel]()
//        transactionCellViewModels.append(TransactionsTableViewCellViewModel())
//        transactionCellViewModels.append(TransactionsTableViewCellViewModel())
//        transactionCellViewModels.append(TransactionsTableViewCellViewModel())
//        transactionCellViewModels.append(TransactionsTableViewCellViewModel())
//        transactionCellViewModels.append(TransactionsTableViewCellViewModel())
//        return transactionCellViewModels
        
        return TransactionsTableViewCellViewModel()
    }
//
    var numberOfSections: Int {
        //TODO: handle sections here
//        let numberOfSections = entityHandler.numberOfSection()
//        guard numberOfSections <= 0 && isAccountTransaction && filter == nil else { return numberOfSections }
//
//        return isSearching ? 0 : 1
        
        return _numberOfSections
    }
//
    func numberOfRows(inSection section: Int) -> Int {
        //TODO: handle rows here
//        let numberOfSections = entityHandler.numberOfSection()
//        if numberOfSections == 0 && !isSearching {  return  10 }
//
//        return entityHandler.numberOfTransaction(in: section)
        return _numberOfRows
    }
    
    private var _numberOfRows = 10
    private var _numberOfSections = 1

    // let repository: TransactionsRepository
    
    private var filter: TransactionFilter?
    private var dataChanged: Bool = false
    private var isFirstTime: Bool = true
    
//    private lazy var entityHandler = CDTransactionEntityHandler(delegate: self)
//    private lazy var pagesEntityHandler = CDTransactionPagesEntityHandler()
    private let cardSerialNumber: String?
    
    private var isAccountTransaction: Bool { cardSerialNumber == nil }
    private var transactionCardType : TransactionCardType { cardSerialNumber == nil ? .debit : .other }
    
    private var isSearching: Bool = false
    private var debitSearch: Bool = false
    init(transactionDataProvider: PaymentCardTransactionProvider, cardSerialNumber: String? = nil, debitSearch: Bool = false) {
        // self.repository = repository
        self.debitSearch = debitSearch
        self.cardSerialNumber = cardSerialNumber
        nothingLabelSubject = BehaviorSubject(value: "screen_home_display_text_nothing_to_report".localized)
        showsFilterSubject = BehaviorSubject(value: true)
        super.init()
        
        showsNothingLabelSubject.onNext(cardSerialNumber != nil)
        
        showShimmeringSubject.debounce(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] IsLoading in
            self?._numberOfRows = IsLoading ? 10 : 0
            self?._numberOfSections = IsLoading ? 1 : 0
            self?.reloadDataSubject.onNext(())
        }).disposed(by: disposeBag)
                
        updateFilter()
//        updateContent()
//        updateGraph()
//
//        let viewAppeared = viewAppearedSubject.do(onNext: { SessionManager.current.refreshBalance() })
        
        
        //Uncomment following
      /*  let request =  Observable.merge(fetchTransactions, viewAppearedSubject.take(1))
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false)})
            .flatMap { _ in transactionDataProvider.fetchTransactions() }
            .share()

        request.subscribe(onNext: { response in
            print(response)
        })
        .disposed(by: disposeBag) */
//
//        let saveRequest = request.elements()
//            .map { [unowned self] pageableResponse -> Bool in
//                let updatedCount = self.entityHandler.update(
//                    with: pageableResponse.content?.indexed ?? [],
//                    transcationCardType: self.transactionCardType,
//                    cardSerialNumber: debitSearch ? cardSerialNumber : nil)
//
//            self.dataChanged = self.dataChanged ? self.dataChanged : updatedCount > 0
//
//            self.pagesEntityHandler.updatePages(for: self.transactionCardType, cardSerialNumber: self.cardSerialNumber, pagesSynced: pageableResponse.currentPage, isLast: pageableResponse.isLast)
//
//            let syncStatus = self.pagesEntityHandler.syncStatus(for: self.transactionCardType, cardSerialNumber: cardSerialNumber)
//
//            let shouldFetchMore = pageableResponse.isLast ? false : updatedCount >= transactionDataProvider.pageSize ? true : !syncStatus.syncCompleted
//
//            if shouldFetchMore {
//                transactionDataProvider.resetPage(updatedCount >= transactionDataProvider.pageSize ? pageableResponse.currentPage + 1 : syncStatus.syncedPages + 1)
//            } else {
//                self.updateContent()
//            }
//
//            return shouldFetchMore
//        }.share()
//
//        saveRequest.filter { $0 }.map { _ in }.bind(to: fetchTransactionsObserver).disposed(by: disposeBag)
//
//        saveRequest.filter { !$0 }
//            .do(onNext: { [weak self] _ in
//                transactionDataProvider.resetPage(0)
//                self?.loadingSubject.onNext(false) })
//            .subscribe(onNext: { [unowned self] _ in self.updateGraph() })
//            .disposed(by: disposeBag)

      /*  request.errors().subscribe(onNext: { [unowned self] _ in
            self.loadingSubject.onNext(false)
            self.dataChanged = false
        }).disposed(by: disposeBag) */

        filterSelectedSubject.subscribe(onNext: { [unowned self] filter in

            self.dataChanged = true
            self.filterCountSubject.onNext(filter?.getFiltersCount() ?? 0)
            self.updateFilter(filter)
//            self.updateContent()
//            self.updateGraph()
        }).disposed(by: disposeBag)
    }
    // check transaction type
    init(/* repository: TransactionsRepository,*/ cardSerialNumber: String? = nil) {
        // self.repository = repository
        self.cardSerialNumber = cardSerialNumber
        nothingLabelSubject = BehaviorSubject(value: "screen_home_display_text_nothing_to_report_search".localized)
        showsFilterSubject = BehaviorSubject(value: false)
//        super.init()
//        isSearching = true
//        showsNothingLabelSubject.onNext(true)
//
//        updateFilter()
//        updateContent()
//
//        searchTextSubject.subscribe(onNext: { [unowned self] in
//            self.searchTransactions(text: $0)
//        }).disposed(by: disposeBag)
    }

}

// MARK: Filter requests

extension TransactionsViewModel {
    
    func updateFilter(_ filter: TransactionFilter? = nil) {
        self.filter = filter
        
        let sortDescriptors = [NSSortDescriptor(key: "transactionDay", ascending: false), NSSortDescriptor(key: "createdDate", ascending: false)]
                
        guard let filter = filter, filter.getFiltersCount() > 0 else {
//            let predicate = isAccountTransaction ? NSPredicate(format: "transactionCardType = %@", transactionCardType.rawValue) : NSPredicate(format: "cardSerialNumber = %@ && transactionCardType = %@", cardSerialNumber!, transactionCardType.rawValue)
//            try? entityHandler.updateFRCRequest(sortDescriptors: sortDescriptors, predicate: predicate, sectionNameKeyPath: "transactionDay")
            return
        }

        var query: String = ""
        var args: [Any] = []

//        if filter.debitSearch != filter.creditSearch {
//            query += "(type == %@)"
//            args.append(filter.creditSearch ? TransactionType.credit.rawValue : TransactionType.debit.rawValue)
//        }
//
//        if filter.pendingSearch {
//            if !query.isEmpty {
//                query += " && "
//            }
//            query += "(status == %@ || status == %@)"
//            args.append(TransactionStatus.pending.rawValue)
//            args.append(TransactionStatus.inProgress.rawValue)
//        }
//
//        if filter.categories.count > 0 {
//            if !query.isEmpty {
//                query += " && "
//            }
//            query += "(merchantCategory IN[c] %@)"
//            args.append(filter.categories.map{ $0.rawValue })
//        }

        if !query.isEmpty {
            query += " && "
        }

        query += "((amount <= %f && amount >= %f && productCode != %@ && productCode != %@) || (settlementAmount <= %f && settlementAmount >= %f && (productCode == %@ || productCode == %@)))"

        args.append(contentsOf: [filter.maxAmount, filter.minAmount, TransactionProductCode.rmt.rawValue, TransactionProductCode.swift.rawValue, filter.maxAmount, filter.minAmount, TransactionProductCode.rmt.rawValue, TransactionProductCode.swift.rawValue])


        query += " && (transactionCardType == %@)"
        args.append(transactionCardType.rawValue)

        if !isAccountTransaction {
            query += " && (cardSerialNumber == %@)"
            args.append(cardSerialNumber!)
        }

//        let predicate: NSPredicate = NSPredicate(format: query, argumentArray: args)
//        try? entityHandler.updateFRCRequest(sortDescriptors: sortDescriptors, predicate: predicate, sectionNameKeyPath: "transactionDay")

    }
}

//// MARK: Transaction entity handler Delegate
//
//extension TransactionsViewModel: CDTransactionEntityHandlerDelegate {
//
//    func entityDidChangeContent(_ entityHandler: CDTransactionEntityHandler) {
//        updateContent()
//    }
//
//    func updateContent() {
//        filterEnabledSubject.onNext(entityHandler.numberOfSection() != 0 || filter != nil)
//        reloadDataSubject.onNext(())
//        showsPlaceholderSubject.onNext(isAccountTransaction && !isSearching)
//        showsNothingLabelSubject.onNext(cardSerialNumber != nil || entityHandler.numberOfSection() == 0)
//        nothingLabelSubject.onNext(filter != nil || isSearching ? "screen_home_display_text_nothing_to_report_search".localized : "screen_home_display_text_nothing_to_report".localized)
//    }
//
//    func updateGraph() {
//        guard dataChanged || isFirstTime else { return }
//        isFirstTime = false
//        dataChanged = false
//        let sectionTransactions = entityHandler.allSections().map { section -> SectionTransaction in
//            let transaction = section.first
//            return SectionTransaction(day: transaction?.transactionDay ?? Date().startOfDay, amount: 0, closingBalance: transaction?.closingBalance ?? 0)
//            }
//
//        transactionSubject.onNext(sectionTransactions)
//    }
//}

private extension TransactionsViewModel {
    func searchTransactions(text: String?) {
//        let sortDescriptors = [NSSortDescriptor(key: "transactionDay", ascending: false), NSSortDescriptor(key: "createdDate", ascending: false)]
//
//        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
//            let predicate = isAccountTransaction ? NSPredicate(format: "transactionCardType = %@", transactionCardType.rawValue) : NSPredicate(format: "cardSerialNumber = %@ && transactionCardType = %@", cardSerialNumber!, transactionCardType.rawValue)
//            try? entityHandler.updateFRCRequest(sortDescriptors: sortDescriptors, predicate: predicate, sectionNameKeyPath: "transactionDay")
//
//            updateContent()
//            return
//        }
//
//        var query: String = ""
//        var args: [Any] = []
//
//        query += "((title CONTAINS[c] %@) || (senderName CONTAINS[c] %@ && type = %@) || (receiverName CONTAINS[c] %@ && type = %@) || merchantCategory CONTAINS[c] %@)"
//
//        args.append(contentsOf: [text, text, TransactionType.credit.rawValue, text, TransactionType.debit.rawValue, text])
//
//        query += " && (transactionCardType == %@)"
//        args.append(transactionCardType.rawValue)
//
//        if !isAccountTransaction {
//            query += " && (cardSerialNumber == %@)"
//            args.append(cardSerialNumber!)
//        }
//
//        let predicate: NSPredicate = NSPredicate(format: query, argumentArray: args)
//
//        try? entityHandler.updateFRCRequest(sortDescriptors: sortDescriptors, predicate: predicate, sectionNameKeyPath: "transactionDay")
//
//        updateContent()
    }
}
