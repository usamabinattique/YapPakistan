//
// TransactionsViewModel.swift
// YAP
//
// Created by Wajahat Hassan on 27/08/2019.
// Copyright © 2019 YAP. All rights reserved.
//
// swiftlint:disable line_length
// swiftlint:disable identifier_name

import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import GLKit
import RxTheme
import UIKit
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
    
    var updateCategoryBarObserver: AnyObserver<Bool> { get }
    var canShowDynamicData: AnyObserver<Bool> { get }
    var showSectionData: AnyObserver<Void>{ get }
    var showTodaysData: AnyObserver<Void> { get }
    
    var isDataReloaded: AnyObserver<Bool> { get }
    var sectionObserver: AnyObserver<Int> { get }
    var refreshObserver: AnyObserver<Void> { get }
    var loadMore: AnyObserver<Void> { get }
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
    var sectionAmount: Observable<String?> { get}
    var sectionDate: Observable<NSMutableAttributedString?> { get }
    var isTableViewReloaded: Observable<Bool> { get }
    var enableLoadMore: Observable<Bool> { get }
    var showLoadMoreIndicator: Observable<Bool> { get }
    var categorySectionCount: Observable<Int> { get }
    var noTransFound: Observable<String> { get }
    var analyticsDate: Observable<Date> { get }
    var categoryBarData: Observable<(MonthData?,Int?)> {get}
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
    private let filterEnabledSubject = BehaviorSubject<Bool>(value: true)
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
    
    private let updateCategoryBarSubject = BehaviorSubject<Bool>(value: false)
    private let showErrorSubject = PublishSubject<String>()
    private let categoryBarDataSubject = BehaviorSubject<(MonthData?, Int?)>(value: (nil, nil))
    public var categorySectionCountSubject = BehaviorSubject<Int>(value: 0)
    private let canShowDynamicDataSubject = BehaviorSubject<Bool>(value: false)
    private let showSectionDataSubject = PublishSubject<Void>()
    private let sectionAmountSubject = BehaviorSubject<String?>(value: nil)
    private let sectionDateSubject = BehaviorSubject<NSMutableAttributedString?>(value: nil)
    private let showTodaysDataSubject = PublishSubject<Void>()
    private let dataReloadedSubject = BehaviorSubject<Bool>(value: false)
    private let sectionSubject = BehaviorSubject<Int>(value: 0)
    private let refreshSubject = ReplaySubject<Void>.create(bufferSize: 1)
    private let loadMoreSubject = PublishSubject<Void>()
    private let pageInfoSubject = ReplaySubject<PagableResponse<TransactionResponse>>.create(bufferSize: 1)
    private let enableLoadMoreSubject = BehaviorSubject<Bool>(value: true)
    public let showLoadMoreIndicatorSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private let noTransFoundSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let analyticsDateSubject = BehaviorSubject<Date>(value: Date())
    
    // MARK: - Input
    var fetchTransactionsObserver: AnyObserver<Void> { return fetchTransactionsSubject.asObserver() }
    var viewAppearedObsever: AnyObserver<Void> { return viewAppearedSubject.asObserver() }
    var transactionDetailsObserver: AnyObserver<CDTransaction> { return transactionDetailsSubject.asObserver() }
    var openWelcomeTutorialObserver: AnyObserver<Void> { openWelcomTutorialSubject.asObserver() }
    var updateCategoryBarObserver: AnyObserver<Bool> { updateCategoryBarSubject.asObserver() }
    var canShowDynamicData: AnyObserver<Bool> {canShowDynamicDataSubject.asObserver()}

    var openFilterObserver: AnyObserver<Void> { return openFilterSubject.asObserver() }
    var filterSelected: AnyObserver<TransactionFilter?> { return filterSelectedSubject.asObserver() }
    var searchTextObserver: AnyObserver<String?> { searchTextSubject.asObserver() }
    var showShimmeringObserver: AnyObserver<Bool> { showShimmeringSubject.asObserver() }
    var showSectionData: AnyObserver<Void>{showSectionDataSubject.asObserver()}
    var showTodaysData: AnyObserver<Void> { showTodaysDataSubject.asObserver() }
    var isDataReloaded: AnyObserver<Bool> {dataReloadedSubject.asObserver()}
    var sectionObserver: AnyObserver<Int> { sectionSubject.asObserver() }
    var refreshObserver: AnyObserver<Void> { refreshSubject.asObserver() }
    var loadMore: AnyObserver<Void> { loadMoreSubject.asObserver() }
    

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
    var sectionAmount: Observable<String?> { sectionAmountSubject.asObservable() }
    var sectionDate: Observable<NSMutableAttributedString?> { sectionDateSubject.asObservable() }
    var isTableViewReloaded: Observable<Bool> { dataReloadedSubject.asObservable() }
    var enableLoadMore: Observable<Bool> { enableLoadMoreSubject.asObservable() }
    var showLoadMoreIndicator: Observable<Bool> { showLoadMoreIndicatorSubject.asObservable() }
    var categorySectionCount: Observable<Int> {categorySectionCountSubject.asObservable()}
    var noTransFound: Observable<String> { noTransFoundSubject.asObservable() }
    var analyticsDate: Observable<Date> {analyticsDateSubject.asObservable()}
    var categoryBarData: Observable<(MonthData?, Int?)>  { categoryBarDataSubject.asObservable() }
    
    
    func sectionViewModel(for section: Int) -> TransactionHeaderTableViewCellViewModelType {
        
        if !isShimmering {
            let transactions = TransactionResponse.transactions(for: section, allTransactions: transactionsObj)
            let amount = transactions.reduce(0, { $1.type == .debit ? $0 - $1.calculatedTotalAmount : $0 + $1.calculatedTotalAmount })
            let date = transactions.first?.date ?? Date().startOfDay
            return TransactionHeaderTableViewCellViewModel(date: date.transactionSectionReadableDate.string, totalTransactionsAmount: (amount < 0 ? "- " : "+ ") +  CurrencyFormatter.formatAmountInLocalCurrency(abs(amount)))
        } else {
            return TransactionHeaderTableViewCellViewModel()
        }
    }

    func cellViewModel(for indexPath: IndexPath) -> ReusableTableViewCellViewModelType {

        if let transaction = TransactionResponse.transaction(for: indexPath, allTransactions: transactionsObj), !isShimmering {
            return TransactionsTableViewCellViewModel(transaction: transaction, themeService: themeServie)
        }

        return TransactionsTableViewCellViewModel()
    }
//
    var numberOfSections: Int {
        let numberOfSections = TransactionResponse.getNumberOfSections(allTransactions: transactionsObj,searchText: searchText).count
        _numberOfSections = numberOfSections
        guard numberOfSections <= 0 && isAccountTransaction && filter == nil else { return numberOfSections }
        
        return (isSearching && self.transactionsObj.isEmpty ) ? 0 : 1
    }
//
    func numberOfRows(inSection section: Int) -> Int {
        if numberOfSections == 0 && !isSearching {
            _numberOfRows = 10
            return  _numberOfRows
        }
        _numberOfRows = TransactionResponse.numberOfTransaction(in: section, allTransactions: transactionsObj)
        return _numberOfRows //entityHandler.numberOfTransaction(in: section)
        
       // return _numberOfRows
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
    var transactionsObj = [TransactionResponse]() {
        didSet {
            if transactionsObj.isEmpty {
                noTransFoundSubject.onNext("No transactions found")
            } else {
                noTransFoundSubject.onNext("")
            }
            //reloadDataSubject.onNext(())
        }
    }
    
    private var themeServie: ThemeService<AppTheme>!
    private var currentSection: Int = 0
    private var showDynamicDataInToolbar = false
    private var isBarDataFetched = false
    private var refreshCategoryBar = false
    private var currentSectionMonth: String = Date().dashboardSectionBarDate
    private var currentBarDateMonth: String = ""
    var latestBalance: String = "0.00"
    private var isShimmering = true
    var pageInfo: PagableResponse<TransactionResponse>!
    
    private var transactionBarData: TransactionBarCategoriesResponse?
    private var searchText: String? {
        didSet {
            isSearching = true
        }
    }
    
    private var repository: TransactionsRepositoryType
    
    init(transactionDataProvider: PaymentCardTransactionProvider, repository: TransactionsRepositoryType ,cardSerialNumber: String? = nil, debitSearch: Bool = false, themService: ThemeService<AppTheme>, showFilter: Bool = true) {
         self.repository = repository
        self.themeServie = themService
        self.debitSearch = debitSearch
        self.cardSerialNumber = cardSerialNumber
        nothingLabelSubject = BehaviorSubject(value: "screen_home_display_text_nothing_to_report".localized)
        showsFilterSubject = BehaviorSubject(value: showFilter)
        super.init()
        
        showShimmeringSubject.debounce(RxTimeInterval.seconds(Int(1)), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] IsLoading in
            self?.isShimmering = IsLoading
            self?._numberOfRows = IsLoading ? 10 : 0
            self?._numberOfSections = IsLoading ? 1 : 0
            self?.reloadDataSubject.onNext(())
        }).disposed(by: disposeBag)
        
        showsNothingLabelSubject.onNext(cardSerialNumber != nil)
        updateFilter()
        updateContent()
        updateGraph()
        getTransactionBar()

        showShimmeringSubject.onNext(true)
       // refreshSubject.onNext(())
        
        //let combine = Observable.combineLatest(pageInfoSubject,showShimmeringSubject)
       loadMoreSubject.withLatestFrom(showShimmeringSubject){ [unowned self] (_,showLoading) -> PagableResponse<TransactionResponse>? in
           // let (page, showLoading) = arg1
           self.enableLoadMoreSubject.onNext(false)
            guard let page = self.pageInfo ,!page.isLast,
                !showLoading
                else {return nil}
            var newPage = page
           newPage.currentPage =  (transactionDataProvider.currentPage) + 1
            return newPage
            }.subscribe(onNext: { [weak self] (page) in
                guard let `self` = self else { return }
                guard let newPage = page
                    else {return}
                transactionDataProvider.resetPage(newPage.currentPage)
                self.fetchTransactionsObserver.onNext(())
                
            }).disposed(by: disposeBag)
        
        
        refreshSubject.withUnretained(self).subscribe(onNext: { `self`,_ in
            print("refresh in transactions")
            self.transactionsObj = []
            transactionDataProvider.resetPage(0)
           // self.showShimmeringSubject.onNext(true)
            self.fetchTransactionsObserver.onNext(())
            
        }).disposed(by: disposeBag)

        
//        viewAppearedSubject.withUnretained(self).subscribe(onNext: { `self`, _ in
//            print("enabled loard more")
//            self.enableLoadMoreSubject.onNext(true)
//        }).disposed(by: disposeBag)

        
        let request =  fetchTransactions //Observable.merge(fetchTransactions, viewAppearedSubject)
            .do(onNext: { [weak self] _ in
//                self?.loadingSubject.onNext(false)
//                self?.showShimmeringSubject.onNext(false)
            //    self?.enableLoadMoreSubject.onNext(false)
                if transactionDataProvider.currentPage > 0 {
                    self?.showLoadMoreIndicatorSubject.onNext(true)
                }
            })
            .flatMap { [weak self]
                _ in
                transactionDataProvider.fetchTransactions(searchText: self?.searchText)
                
            }
            .share()
        
     /*   let saveRequest =  request.elements().map { [unowned self] pageableResponse -> Bool in
            
            self.enableLoadMoreSubject.onNext(true)
            self.showShimmeringSubject.onNext(false)
            self.loadingSubject.onNext(false)
            
            self.pageInfoSubject.onNext(pageableResponse)
            
            if pageableResponse.isLast {
                self.transactionsObj = pageableResponse.content ?? []
            } else {
                self.transactionsObj.append(contentsOf: pageableResponse.content ?? [])
            }
            self.updateContent()
            let shouldFetchMore = pageableResponse.isLast ? false : true //pageableResponse.t
            return shouldFetchMore
        }.share() */
        
        request.elements().subscribe(onNext:  { [unowned self] pageableResponse in
            self.pageInfo = pageableResponse
            self.enableLoadMoreSubject.onNext(true)
            self.showShimmeringSubject.onNext(false)
            self.loadingSubject.onNext(false)
            
            if pageableResponse.currentPage == 0 {
                self.transactionsObj = pageableResponse.content ?? []
            } else {
                if (pageableResponse.content?.isEmpty ?? false) {
                    self.transactionsObj = []
                } else {
                    self.transactionsObj.append(contentsOf: pageableResponse.content ?? [])
                }
                
                self.showLoadMoreIndicatorSubject.onNext(false)
            }
            
            self.updateContent()
            if !pageableResponse.isLast {
                self.updateGraph()
            }
        }).disposed(by: disposeBag)

        
       // saveRequest.filter { $0 }.map { _ in }.bind(to: fetchTransactionsObserver).disposed(by: disposeBag)
        
      /*  saveRequest.filter { !$0 }
            .do(onNext: { [weak self] _ in
                transactionDataProvider.resetPage(0)
                self?.loadingSubject.onNext(false) })
            .subscribe(onNext: { [unowned self] _ in /*self.updateGraph() */ })
            .disposed(by: disposeBag) */
        
        request.errors().subscribe(onNext: { [unowned self] _ in
            self.enableLoadMoreSubject.onNext(true)
            self.showShimmeringSubject.onNext(false)
            self.loadingSubject.onNext(false)
            self.dataChanged = false
            self.showLoadMoreIndicatorSubject.onNext(false)
        }).disposed(by: disposeBag)
        
        filterSelectedSubject.subscribe(onNext: { [unowned self] filter in
            
            self.dataChanged = true
            self.filterCountSubject.onNext(filter?.getFiltersCount() ?? 0)
            self.updateFilter(filter)
            transactionDataProvider.transactionFilter = filter
            self.pageInfo.currentPage = 0
            self.fetchTransactionsObserver.onNext(())
            //self.updateContent()
            self.updateGraph()
        }).disposed(by: disposeBag)
        
        sectionSubject.subscribe(onNext: {[unowned self] section in
            self.currentSection = section
            self.getFinalDate()
            self.getFinalBalance()
        }).disposed(by: disposeBag)
        
        dataReloadedSubject
            .take(until: { val in
                val == true
            })
            .subscribe(onNext: {[weak self] in
                $0 ? self?.tableViewReloaded() : nil
            }).disposed(by: disposeBag)
        
        showTodaysDataSubject.subscribe(onNext: {[weak self] _ in
            if self?.currentSection == 0 {
                self?.sectionDateSubject.onNext(NSMutableAttributedString(string: "screen_home_todays_balance_title".localized) )
            }
        }).disposed(by: disposeBag)
        
        showSectionDataSubject.subscribe(onNext: {[weak self] _ in
            self?.getFinalBalance()
        }).disposed(by: disposeBag)
        
        canShowDynamicDataSubject.subscribe(onNext: {[weak self] value in
            self?.showDynamicDataInToolbar = value
        }).disposed(by: disposeBag)
        
        updateCategoryBarSubject.subscribe(onNext: {[unowned self] in
            self.refreshCategoryBar = $0
        }).disposed(by: disposeBag)
        
        searchTextSubject.distinctUntilChanged().throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { [unowned self]  in
//            guard let text = $0, text != "" else {
//                self.searchText = nil
//                return
//            }
            
            if let text = $0, text == "" {
                self.searchText = nil
            } else {
                self.searchText = $0
            }
            
            
            self.fetchTransactionsObserver.onNext(())
            //self.searchTransactions(text: text)
           
        }).disposed(by: disposeBag)
        
    }
    
    
    
    // check transaction type
    init( repository: TransactionsRepositoryType, cardSerialNumber: String? = nil) {
         self.repository = repository
        self.cardSerialNumber = cardSerialNumber
        nothingLabelSubject = BehaviorSubject(value: "screen_home_display_text_nothing_to_report_search".localized)
        showsFilterSubject = BehaviorSubject(value: false)
        super.init()
        isSearching = true
        showsNothingLabelSubject.onNext(true)

        updateFilter()
        updateContent()

//        searchTextSubject.subscribe(onNext: { [unowned self] in
//            self.searchTransactions(text: $0)
//        }).disposed(by: disposeBag)
        
        
        
    }

}

// MARK: Filter requests

extension TransactionsViewModel {
    
    func updateFilter(_ filter: TransactionFilter? = nil) {
        self.filter = filter
        
      /*
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
//        try? entityHandler.updateFRCRequest(sortDescriptors: sortDescriptors, predicate: predicate, sectionNameKeyPath: "transactionDay") */

    }
}

// MARK: Transaction entity handler Delegate
extension TransactionsViewModel {

    func entityDidChangeContent() {
        updateContent()
    }

    func updateContent() {
        
        filterEnabledSubject.onNext(TransactionResponse.getNumberOfSections(allTransactions: transactionsObj).count != 0 || filter != nil)
        reloadDataSubject.onNext(())
        showsPlaceholderSubject.onNext(isAccountTransaction && !isSearching)
        showsNothingLabelSubject.onNext(cardSerialNumber != nil || TransactionResponse.getNumberOfSections(allTransactions: transactionsObj).count == 0)
        nothingLabelSubject.onNext(filter != nil || isSearching ? "screen_home_display_text_nothing_to_report_search".localized : "screen_home_display_text_nothing_to_report".localized)
    }

    func updateGraph() {
        guard dataChanged || isFirstTime else { return }
        isFirstTime = false
        dataChanged = false
        let sectionTransactions = TransactionResponse.getNumberOfSections(allTransactions: transactionsObj, searchText: self.searchText).map { section -> SectionTransaction in
            let transaction = section.transactions.first
            return SectionTransaction(day: transaction?.date.startOfDay ?? Date().startOfDay, amount: 0, closingBalance: transaction?.closingBalance ?? 0)
            }

        transactionSubject.onNext(sectionTransactions)
    }
}

private extension TransactionsViewModel {
    func searchTransactions(text: String?) {
        self.searchText = text
        updateContent()
    }
}

extension TransactionsViewModel {
    func getFinalBalance() {
        let transactions = TransactionResponse.transactions(for: self.currentSection, allTransactions: transactionsObj) //entityHandler.transactions(for: self.currentSection)
        if transactions.count > 0 {
            if self.currentSection == 0 {
                self.sectionAmountSubject.onNext("\(self.latestBalance)")
            }
            else {
                self.sectionAmountSubject.onNext(transactions[0].closingBalance?.twoDecimal() ?? "")
            }
        }
    }
    
    func getFinalDate() {
        let transactions = TransactionResponse.transactions(for: currentSection, allTransactions: transactionsObj) //entityHandler.transactions(for: self.currentSection)
        if transactions.count > 0 { //&& self.showDynamicDataInToolbar {
            let date = transactions.first?.date ?? Date().startOfDay
            analyticsDateSubject.onNext(date)
            self.currentSectionMonth = date.dashboardSectionBarDate
            changeAnaliticsBar()
            if Calendar.current.isDateInToday(date){
                self.sectionDateSubject.onNext(NSMutableAttributedString(string: "screen_home_todays_balance_title".localized))
            }
            else {
                self.sectionDateSubject.onNext(date.transactionSectionReadableDate)
            }
        }
    }
    
    func tableViewReloaded() {
        self.sectionDateSubject.onNext(NSMutableAttributedString(string: "screen_home_todays_balance_title".localized))
    }
}

fileprivate extension TransactionsViewModel {
    
    func getTransactionBar() {
       // showLoaderSubject.onNext(true)
        let request = repository.getTransactionCategories().share() /* viewDidLoadSubject
            .do(onNext: {[weak self] _ in self?.showLoaderSubject.onNext(true)})
            .flatMap { [weak self]  in
                (self?.repository.getTransactionCategories())!
            }
            .share(replay: 1, scope: .whileConnected) */
        
        request.elements()
            .do(onNext: { [weak self] _ in
                   // self?.showLoaderSubject.onNext(false)
                print("response")
            })
            .subscribe(onNext: {[weak self] in
                self?.transactionBarData = $0
                self?.getNumberOfCategorySection()
                self?.getFirstSectionDate()
                self?.isBarDataFetched = true
                self?.changeAnaliticsBar()
        }).disposed(by: disposeBag)
        
        
        request
            .errors()
            .do(onNext: { [weak self] _ in
                //self?.showLoaderSubject.onNext(false)
                print("error")
            })
                .subscribe(onNext: { err in
                    print(err.localizedDescription)
                }).disposed(by: disposeBag)
        
    }
    
    func changeAnaliticsBar(){
        if !isBarDataFetched {
          return
        }
        guard let barData = transactionBarData else {return}
        if self.currentBarDateMonth != currentSectionMonth || refreshCategoryBar{
            self.currentBarDateMonth = currentSectionMonth
            let monthData =  barData.monthData.filter {$0.date ==  self.currentBarDateMonth}.first
            categoryBarDataSubject.onNext((monthData, self.currentSection))
        }
    }
    
    func getFirstSectionDate() {
        let transactions = TransactionResponse.transactions(for: 0, allTransactions: transactionsObj)
        if transactions.count > 0 {
            let date = transactions.first?.date.startOfDay ?? Date().startOfDay
            self.currentSectionMonth = date.dashboardSectionBarDate
            analyticsDateSubject.onNext(date)
        }
    }
    
    func getNumberOfCategorySection() {
        var sectionList: [Int] = []
        guard let monthData = transactionBarData?.monthData else {return}
        for data in monthData {
            sectionList.append(data.categories.count)
        }
        categorySectionCountSubject.onNext(sectionList.max() ?? 0)
    }
    
}
