//
//  HomeTransactionsViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 13/04/2022.
//
/*
import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
//import Networking
import CoreData
//import AppDatabase

public protocol HomeTransactionsViewModelInputs {
    var fetchTransactionsObserver: AnyObserver<Void> { get }
    var viewAppearedObsever: AnyObserver<Void> { get }
    var viewDidLoadObsever: AnyObserver<Void> { get }
    var transactionDetailsObserver: AnyObserver<CDTransaction> { get }
    var openFilterObserver: AnyObserver<Void> { get }
    var filterSelected: AnyObserver<TransactionFilter?> { get }
    var openWelcomeTutorialObserver: AnyObserver<Void> { get }
    var searchTextObserver: AnyObserver<String?> { get }
    var sectionObserver: AnyObserver<Int> { get }
    var isDataReloaded: AnyObserver<Bool> { get }
    var showTodaysData: AnyObserver<Void> {get}
    var showSectionData: AnyObserver<Void> {get}
    var canShowDynamicData: AnyObserver<Bool> { get }
    var updateCategoryBarObserver: AnyObserver<Bool> { get }
}

public protocol HomeTransactionsViewModelOutputs {
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
    var analyticsDate: Observable<Date> {get}
    var reloadData: Observable<Void> { get }
    func sectionViewModel(for section: Int) -> TransactionHeaderTableViewCellViewModelType
    func cellViewModel(for indexPath: IndexPath) -> ReusableTableViewCellViewModelType
    var numberOfSections: Int { get }
    func numberOfRows(inSection section: Int) -> Int
    var showsGraph: Observable<Bool> { get }
    var loading: Observable<Bool> { get }
    var nothingLabelText: Observable<String?> { get }
    var showsFilter: Observable<Bool> { get }
    var sectionDate: Observable<NSMutableAttributedString?> { get }
    var sectionAmount: Observable<String?> { get }
    var currentBalance: Observable<[Balance]> { get }
    var isTableViewReloaded: Observable<Bool> { get }
    var showLoader: Observable<Bool> {get}
    var showError: Observable<String> { get }
    var categoryBarData: Observable<(MonthData?,Int?)> {get}
    var categorySectionCount: Observable<Int> { get }
}

public protocol HomeTransactionsViewModelType {
    var inputs: HomeTransactionsViewModelInputs { get }
    var outputs: HomeTransactionsViewModelOutputs { get }
}

public class HomeTransactionsViewModel: NSObject, HomeTransactionsViewModelType, HomeTransactionsViewModelInputs, HomeTransactionsViewModelOutputs {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    public var inputs: HomeTransactionsViewModelInputs { return self }
    public var outputs: HomeTransactionsViewModelOutputs { return self }
    private var dataProvider: DebitCardTransactionsProvider?

    private let transactionTableViewCellViewModelSubject = BehaviorSubject<[SectionModel<(date: String, amount: String), ReusableTableViewCellViewModelType>]>(value: [])
    private let fetchTransactionsSubject = PublishSubject<Void>()
    private let transactionSubject = BehaviorSubject<[SectionTransaction]>(value: [])
    private let showsPlaceholderSubject = BehaviorSubject<Bool>(value: true)
    private let viewAppearedSubject = PublishSubject<Void>()
    private let viewDidLoadSubject = PublishSubject<Void>()
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
    private let sectionSubject = BehaviorSubject<Int>(value: 0)
    private let sectionDateSubject = BehaviorSubject<NSMutableAttributedString?>(value: nil)
    private let sectionAmountSubject = BehaviorSubject<String?>(value: nil)
    private let currentBalanceSubject = BehaviorSubject<[Balance]>(value: [Balance.defaultBalance])
    private let dataReloadedSubject = BehaviorSubject<Bool>(value: false)
    private let showTodaysDataSubject = PublishSubject<Void>()
    private let showSectionDataSubject = PublishSubject<Void>()
    private let canShowDynamicDataSubject = BehaviorSubject<Bool>(value: false)
    private let analyticsDateSubject = BehaviorSubject<Date>(value: Date())
    private let showLoaderSubject = BehaviorSubject<Bool>(value: false)
    private let updateCategoryBarSubject = BehaviorSubject<Bool>(value: false)
    private let showErrorSubject = PublishSubject<String>()
    private let categoryBarDataSubject = BehaviorSubject<(MonthData?, Int?)>(value: (nil, nil))
    public var categorySectionCountSubject = BehaviorSubject<Int>(value: 0)

    // MARK: - Input
    public var fetchTransactionsObserver: AnyObserver<Void> { return fetchTransactionsSubject.asObserver() }
    public var viewAppearedObsever: AnyObserver<Void> { return viewAppearedSubject.asObserver() }
    public var viewDidLoadObsever: AnyObserver<Void> { return viewDidLoadSubject.asObserver() }
    public var transactionDetailsObserver: AnyObserver<CDTransaction> { return transactionDetailsSubject.asObserver() }
    public var openWelcomeTutorialObserver: AnyObserver<Void> { openWelcomTutorialSubject.asObserver() }
    public var openFilterObserver: AnyObserver<Void> { return openFilterSubject.asObserver() }
    public var filterSelected: AnyObserver<TransactionFilter?> { return filterSelectedSubject.asObserver() }
    public var searchTextObserver: AnyObserver<String?> { searchTextSubject.asObserver() }
    public var sectionObserver: AnyObserver<Int> { sectionSubject.asObserver() }
    public var isDataReloaded: AnyObserver<Bool> {dataReloadedSubject.asObserver()}
    public var showTodaysData: AnyObserver<Void> {showTodaysDataSubject.asObserver()}
    public var showSectionData: AnyObserver<Void>{showSectionDataSubject.asObserver()}
    public var canShowDynamicData: AnyObserver<Bool> {canShowDynamicDataSubject.asObserver()}
    public var updateCategoryBarObserver: AnyObserver<Bool> { updateCategoryBarSubject.asObserver() }

    // MARK: - Output
    public var fetchTransactions: Observable<Void> { return fetchTransactionsSubject.asObservable() }
    public var transactionTableViewCellViewModel: Observable<[SectionModel<(date: String, amount: String), ReusableTableViewCellViewModelType>]> { return transactionTableViewCellViewModelSubject.asObservable() }
    public var transactionDetails: Observable<CDTransaction> { return transactionDetailsSubject.asObservable() }
    public var openFilter: Observable<TransactionFilter?> { return  openFilterSubject.map { [weak self] in self?.filter } }
    public var filterEnabled: Observable<Bool> { return filterEnabledSubject.asObservable() }
    public var reloadData: Observable<Void> { return reloadDataSubject.asObservable() }
    public var showsPlaceholder: Observable<Bool> { return showsPlaceholderSubject.asObservable() }
    public var filterCount: Observable<Int> { return filterCountSubject.asObservable() }
    public var transactions: Observable<[SectionTransaction]> { return transactionSubject.asObservable() }
    public var showsNothingLabel: Observable<Bool> { showsNothingLabelSubject.asObservable() }
    public var openWelcomTutorial: Observable<Void> { openWelcomTutorialSubject.asObservable() }
    public var showsGraph: Observable<Bool> { showsGraphSubject.asObservable() }
    public var loading: Observable<Bool> { loadingSubject.asObservable() }
    public var nothingLabelText: Observable<String?> { nothingLabelSubject.asObservable() }
    public var showsFilter: Observable<Bool> { showsFilterSubject.asObservable() }
    public var currentBalance: Observable<[Balance]> { currentBalanceSubject }
    public var isTableViewReloaded: Observable<Bool> {dataReloadedSubject}
    public var sectionDate: Observable<NSMutableAttributedString?>{sectionDateSubject}
    public var sectionAmount: Observable<String?> {sectionAmountSubject}
    public var analyticsDate: Observable<Date> {analyticsDateSubject}
    public var showLoader: Observable<Bool> {showLoaderSubject}
    public var showError: Observable<String> { return showErrorSubject.asObservable() }
    public var categoryBarData: Observable<(MonthData?, Int?)>  {return categoryBarDataSubject}
    public var categorySectionCount: Observable<Int> {categorySectionCountSubject}
    
    
    public func sectionViewModel(for section: Int) -> TransactionHeaderTableViewCellViewModelType {
        
        let transactions = entityHandler.transactions(for: section)
        let amount = transactions.reduce(0, { $1.transactionType == .debit ? $0 - $1.calculatedTotalAmount : $0 + $1.calculatedTotalAmount })
        let date = transactions.first?.transactionDay ?? Date().startOfDay
        
        return TransactionHeaderTableViewCellViewModel(date: date.transactionSectionReadableDate, totalTransactionsAmount: (amount < 0 ? "- " : "+ ") +  CurrencyFormatter.formatAmountInLocalCurrency(abs(amount)))
    }
    
    public func cellViewModel(for indexPath: IndexPath) -> ReusableTableViewCellViewModelType {
        
        if let transaction = entityHandler.transaction(for: indexPath) {
            return TransactionsTableViewCellViewModel(transaction: transaction)
        }
        
        return TransactionsTableViewCellViewModel()
    }
    
    public var numberOfSections: Int {
        let numberOfSections = entityHandler.numberOfSection()
        guard numberOfSections <= 0 && isAccountTransaction && filter == nil else { return numberOfSections }
        return isSearching ? 0 : 1
    }
    
    private var currentSection: Int = 0
    private var showDynamicDataInToolbar = false
    private var isBarDataFetched = false
    private var refreshCategoryBar = false
//    private var currentSectionMonth: String = Date().dashboardSectionBarDate
    private var currentBarDateMonth: String = ""
    public func numberOfRows(inSection section: Int) -> Int {
        
        let numberOfSections = entityHandler.numberOfSection()
        if numberOfSections == 0 && !isSearching {  return  10 }
        
        return entityHandler.numberOfTransaction(in: section)
    }

    let repository: TransactionsRepository
    
    private var filter: TransactionFilter?
    private var dataChanged: Bool = false
    private var isFirstTime: Bool = true
    private var transactionBarData: TransactionBarCategoriesResponse?
//    private lazy var entityHandler = CDTransactionEntityHandler(delegate: self)
//    private lazy var pagesEntityHandler = CDTransactionPagesEntityHandler()
    private let cardSerialNumber: String?
    
    private var isAccountTransaction: Bool { cardSerialNumber == nil }
    private var transactionCardType : TransactionCardType { cardSerialNumber == nil ? .debit : .other }
    
    private var isSearching: Bool = false
    private var debitSearch: Bool = false
    private var latestBalance: String = "0.00"
    public init(repository: TransactionsRepository = TransactionsRepository(), transactionDataProvider: PaymentCardTransactionProvider, cardSerialNumber: String? = nil, debitSearch: Bool = false) {
        self.repository = repository
        self.debitSearch = debitSearch
        self.cardSerialNumber = cardSerialNumber
        nothingLabelSubject = BehaviorSubject(value: "screen_home_display_text_nothing_to_report".localized)
        showsFilterSubject = BehaviorSubject(value: true)
        super.init()
        
        showsNothingLabelSubject.onNext(cardSerialNumber != nil)
        updateFilter()
        updateContent()
        updateGraph()
        getTransactionBar()
        
        viewAppearedSubject.do(onNext: { SessionManager.current.refreshBalance() }).subscribe().disposed(by: disposeBag)
        
        SessionManager.current.currentBalance.subscribe(onNext: {[weak self] args in
            self?.latestBalance = args.balance
        }).disposed(by: disposeBag)
        
        let request =  Observable.merge(fetchTransactions, viewAppearedSubject)
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false)})
            .flatMap { _ in transactionDataProvider.fetchTransactions() }
            .share()
        
        let saveRequest = request.elements().map { [unowned self] pageableResponse -> Bool in
            let updatedCount = self.entityHandler.update(with: pageableResponse.content?.indexed ?? [], transcationCardType: self.transactionCardType, cardSerialNumber: debitSearch ? cardSerialNumber : nil)
            
            self.dataChanged = self.dataChanged ? self.dataChanged : updatedCount > 0
            
            self.pagesEntityHandler.updatePages(for: self.transactionCardType, cardSerialNumber: self.cardSerialNumber, pagesSynced: pageableResponse.currentPage, isLast: pageableResponse.isLast)
            
            let syncStatus = self.pagesEntityHandler.syncStatus(for: self.transactionCardType, cardSerialNumber: cardSerialNumber)
            
            let shouldFetchMore = pageableResponse.isLast ? false : updatedCount >= transactionDataProvider.pageSize ? true : !syncStatus.syncCompleted
            
            if shouldFetchMore {
                transactionDataProvider.resetPage(updatedCount >= transactionDataProvider.pageSize ? pageableResponse.currentPage + 1 : syncStatus.syncedPages + 1)
            } else {
                self.updateContent()
            }
            
            return shouldFetchMore
        }.share()
        
        saveRequest.filter { $0 }.map { _ in }.bind(to: fetchTransactionsObserver).disposed(by: disposeBag)
        
        saveRequest.filter { !$0 }
            .do(onNext: { [weak self] _ in
                transactionDataProvider.resetPage(0)
                self?.loadingSubject.onNext(false) })
            .subscribe(onNext: { [unowned self] _ in self.updateGraph() })
            .disposed(by: disposeBag)
        
        request.errors().subscribe(onNext: { [unowned self] _ in
            self.loadingSubject.onNext(false)
            self.dataChanged = false
        }).disposed(by: disposeBag)
        
        filterSelectedSubject.subscribe(onNext: { [unowned self] filter in
            
            self.dataChanged = true
            self.filterCountSubject.onNext(filter?.getFiltersCount() ?? 0)
            self.updateFilter(filter)
            self.updateContent()
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
                self?.sectionDateSubject.onNext(NSMutableAttributedString(string: "screen_home_todays_balance_title".localized))
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
    }
    // check transaction type
    init(repository: TransactionsRepository = TransactionsRepository(), cardSerialNumber: String? = nil) {
        self.repository = repository
        self.cardSerialNumber = cardSerialNumber
        nothingLabelSubject = BehaviorSubject(value: "screen_home_display_text_nothing_to_report_search".localized)
        showsFilterSubject = BehaviorSubject(value: false)
        super.init()
        isSearching = true
        showsNothingLabelSubject.onNext(true)
        updateFilter()
        updateContent()
        
        searchTextSubject.subscribe(onNext: { [unowned self] in
            self.searchTransactions(text: $0)
        }).disposed(by: disposeBag)
    }

}

// MARK: Filter requests

extension HomeTransactionsViewModel {
    
    func updateFilter(_ filter: TransactionFilter? = nil) {
        self.filter = filter
        
        let sortDescriptors = [NSSortDescriptor(key: "transactionDay", ascending: false), NSSortDescriptor(key: "createdDate", ascending: false)]
                
        guard let filter = filter, filter.getFiltersCount() > 0 else {
            let predicate = isAccountTransaction ? NSPredicate(format: "transactionCardType = %@", transactionCardType.rawValue) : NSPredicate(format: "cardSerialNumber = %@ && transactionCardType = %@", cardSerialNumber!, transactionCardType.rawValue)
            try? entityHandler.updateFRCRequest(sortDescriptors: sortDescriptors, predicate: predicate, sectionNameKeyPath: "transactionDay")
            return
        }
        
        var query: String = ""
        var args: [Any] = []
        
        if filter.debitSearch != filter.creditSearch {
            query += "(type == %@)"
            args.append(filter.creditSearch ? TransactionType.credit.rawValue : TransactionType.debit.rawValue)
        }
        
        if filter.pendingSearch {
            if !query.isEmpty {
                query += " && "
            }
            query += "(status == %@ || status == %@)"
            args.append(TransactionStatus.pending.rawValue)
            args.append(TransactionStatus.inProgress.rawValue)
        }
        
        if filter.categories.count > 0 {
            if !query.isEmpty {
                query += " && "
            }
            query += "(merchantCategory IN[c] %@)"
            args.append(filter.categories.map{ $0.rawValue })
        }
        
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
        
        let predicate: NSPredicate = NSPredicate(format: query, argumentArray: args)
        
        try? entityHandler.updateFRCRequest(sortDescriptors: sortDescriptors, predicate: predicate, sectionNameKeyPath: "transactionDay")
    }
}

// MARK: Transaction entity handler Delegate

extension HomeTransactionsViewModel: CDTransactionEntityHandlerDelegate {
    
    public func entityDidChangeContent(_ entityHandler: CDTransactionEntityHandler) {
        updateContent()
    }
    
    func updateContent() {
        filterEnabledSubject.onNext(entityHandler.numberOfSection() != 0 || filter != nil)
        reloadDataSubject.onNext(())
        showsPlaceholderSubject.onNext(isAccountTransaction && !isSearching)
        showsNothingLabelSubject.onNext(cardSerialNumber != nil || entityHandler.numberOfSection() == 0)
        nothingLabelSubject.onNext(filter != nil || isSearching ? "screen_home_display_text_nothing_to_report_search".localized : "screen_home_display_text_nothing_to_report".localized)
    }
    
    func updateGraph() {
        guard dataChanged || isFirstTime else { return }
        isFirstTime = false
        dataChanged = false
        let sectionTransactions = entityHandler.allSections().map { section -> SectionTransaction in
            let transaction = section.first
            return SectionTransaction(day: transaction?.transactionDay ?? Date().startOfDay, amount: 0, closingBalance: transaction?.closingBalance ?? 0)
            }
        
        transactionSubject.onNext(sectionTransactions)
    }
    
    func tableViewReloaded() {
        self.sectionDateSubject.onNext(NSMutableAttributedString(string: "screen_home_todays_balance_title".localized))
    }

    func getFinalBalance() {
        let transactions = entityHandler.transactions(for: self.currentSection)
        if transactions.count > 0 {
            if self.currentSection == 0 {
                self.sectionAmountSubject.onNext("\(self.latestBalance)")
            }
            else {
                self.sectionAmountSubject.onNext("\(transactions[0].closingBalance.twoDecimal())")
            }
        }
    }
    
    func getFinalDate() {
        let transactions = entityHandler.transactions(for: self.currentSection)
        if transactions.count > 0 && self.showDynamicDataInToolbar {
            let date = transactions.first?.transactionDay ?? Date().startOfDay
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
    
    func getTransactionBar() {
        
        let request = viewDidLoadSubject
            .do(onNext: {[weak self] _ in self?.showLoaderSubject.onNext(true)})
            .flatMap { [weak self]  in
                (self?.repository.getTransactionCategories())!
            }
            .share(replay: 1, scope: .whileConnected)
        
        request.elements()
            .do(onNext: { [weak self] _ in
                    self?.showLoaderSubject.onNext(false)})
            .subscribe(onNext: {[weak self] in
                self?.transactionBarData = $0
                self?.getNumberOfCategorySection()
                self?.getFirstSectionDate()
                self?.isBarDataFetched = true
                self?.changeAnaliticsBar()
        }).disposed(by: disposeBag)
        
        
        request
            .errors()
            .do(onNext: { [weak self] _ in self?.showLoaderSubject.onNext(false) })
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
        let transactions = entityHandler.transactions(for: 0)
        if transactions.count > 0 {
            let date = transactions.first?.transactionDay ?? Date().startOfDay
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

private extension HomeTransactionsViewModel {
    func searchTransactions(text: String?) {
        let sortDescriptors = [NSSortDescriptor(key: "transactionDay", ascending: false), NSSortDescriptor(key: "createdDate", ascending: false)]
                
        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            let predicate = isAccountTransaction ? NSPredicate(format: "transactionCardType = %@", transactionCardType.rawValue) : NSPredicate(format: "cardSerialNumber = %@ && transactionCardType = %@", cardSerialNumber!, transactionCardType.rawValue)
            try? entityHandler.updateFRCRequest(sortDescriptors: sortDescriptors, predicate: predicate, sectionNameKeyPath: "transactionDay")
            
            updateContent()
            return
        }
        
        var query: String = ""
        var args: [Any] = []
        
        query += "((finalizedTitle CONTAINS[c] %@) || (senderName CONTAINS[c] %@ && type = %@) || (receiverName CONTAINS[c] %@ && type = %@) || merchantCategory CONTAINS[c] %@ || merchantName CONTAINS[c] %@)"
        
        args.append(contentsOf: [text, text, TransactionType.credit.rawValue, text, TransactionType.debit.rawValue, text, text])
        
        query += " && (transactionCardType == %@)"
        args.append(transactionCardType.rawValue)
        
        if !isAccountTransaction {
            query += " && (cardSerialNumber == %@)"
            args.append(cardSerialNumber!)
        }
        
        let predicate: NSPredicate = NSPredicate(format: query, argumentArray: args)
        
        try? entityHandler.updateFRCRequest(sortDescriptors: sortDescriptors, predicate: predicate, sectionNameKeyPath: "transactionDay")
        
        updateContent()
    }
}
*/
