//
//  CardStatementViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 28/04/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPComponents

protocol StatementViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var customDateObserver: AnyObserver<Void> { get }
    var decrementYearObserver: AnyObserver<Void> { get }
    var incrementYearObserver: AnyObserver<Void> { get }
    var viewWillAppearObserver: AnyObserver<Void> { get }
    var customDateStatementObserver: AnyObserver<Void> { get }
    var customDateRefreshObserver: AnyObserver<DateRangeSelected> { get }
}

protocol StatementViewModelOutput {
    var back: Observable<Void> { get }
    var customDateView: Observable<Void> { get }
    var viewStatement: Observable<WebContentType> { get }
    var decrementEnabled: Observable<Bool> { get }
    var incrementEnabled: Observable<Bool> { get }
    var year: Observable<String?> { get }
    var error: Observable<String> { get }
    var title: Observable<String?> { get }
    var lastFinYearDescription: Observable<String?> { get }
    var yearToDateDescription: Observable<String?> { get }
    var customDateDescription: Observable<String?> { get }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
}

protocol StatementViewModelType {
    var inputs: StatementViewModelInput { get }
    var outputs: StatementViewModelOutput { get }
}

class StatementViewModel: StatementViewModelType, StatementViewModelInput, StatementViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: StatementViewModelInput { return self }
    var outputs: StatementViewModelOutput { return self }
    
    private let backSubject = PublishSubject<Void>()
    private let customDateViewSubject = PublishSubject<Void>()
    private let decrementYearSubject = PublishSubject<Void>()
    private let incrementYearSubject = PublishSubject<Void>()
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let viewStatementSubject = PublishSubject<WebContentType>()
    private let decrementEnabledSubject = BehaviorSubject<Bool>(value: false)
    private let incrementEnabledSubject = BehaviorSubject<Bool>(value: false)
    private let yearSubject = BehaviorSubject<String?>(value: "2022")
    private let errorSubject = PublishSubject<String>()
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let currentIndexSubject = BehaviorSubject<Int>(value: 0)
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let customDateStatementSubject = PublishSubject<Void>()
    private let customDateRefreshSubject = PublishSubject<DateRangeSelected>()
    
    private let lastFinYearDescriptionSubject = BehaviorSubject<String?>(value: nil)
    private let yearToDateDescriptionSubject = BehaviorSubject<String?>(value: nil)
    private let customDateDescriptionSubject = BehaviorSubject<String?>(value: nil)
    
    // MARK: - Inputs
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var customDateObserver: AnyObserver<Void> { customDateViewSubject.asObserver() }
    var decrementYearObserver: AnyObserver<Void> { return decrementYearSubject.asObserver() }
    var incrementYearObserver: AnyObserver<Void> { return incrementYearSubject.asObserver() }
    var viewWillAppearObserver: AnyObserver<Void> { return viewWillAppearSubject.asObserver() }
    var customDateStatementObserver: AnyObserver<Void> { customDateStatementSubject.asObserver() }
    var customDateRefreshObserver: AnyObserver<DateRangeSelected> { customDateRefreshSubject.asObserver() }
    
    // MARK: - Outputs
    var back: Observable<Void> { return backSubject.asObservable() }
    var customDateView: Observable<Void> { customDateViewSubject.asObservable() }
    var viewStatement: Observable<WebContentType> { return viewStatementSubject.asObservable() }
    var incrementEnabled: Observable<Bool> { return incrementEnabledSubject.asObservable() }
    var decrementEnabled: Observable<Bool> { return decrementEnabledSubject.asObserver() }
    var year: Observable<String?> { return yearSubject.asObservable() }
    var error: Observable<String> { return errorSubject.asObservable() }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var title: Observable<String?> { titleSubject.asObservable() }
    var lastFinYearDescription: Observable<String?> { lastFinYearDescriptionSubject.asObservable() }
    var yearToDateDescription: Observable<String?> { yearToDateDescriptionSubject.asObservable() }
    var customDateDescription: Observable<String?> { customDateDescriptionSubject.asObservable() }
    
    private let repository: StatementsRepositoryType
    
    private let yearFomatter = DateFormatter()
    
    // MARK: - Init
    init(statementFetchable: StatementFetchable?, repository: StatementsRepositoryType) {
        yearFomatter.dateFormat = "yyyy"
        self.repository = repository
        yearSubject.onNext(yearFomatter.string(from: Date()))
        
        let currentYear = Date().year
        let previousYear = currentYear - 1
        lastFinYearDescriptionSubject.onNext("July 01, \(previousYear) - June 30, \(currentYear)")
        
        let currentDateFormatted = Date().dateString(ofStyle: .long)
        yearToDateDescriptionSubject.onNext("January 01, \(currentYear) - \(currentDateFormatted)")
        customDateDescriptionSubject.onNext("Export a statement between specific dates")
        
        titleSubject.onNext(statementFetchable?.statementType.viewTitle)
        
        fetchCustomDateStatements(statementFetchable: statementFetchable)
        
        let cardStatementRequest = viewWillAppearSubject.take(1)
            .do(onNext: { YAPProgressHud.showProgressHud() })
            .flatMap { [unowned self] _ -> Observable<Event<[Statement]?>> in
                
                switch statementFetchable!.statementType {
                case .card:
                    return self.repository.getCardStatement(serialNumber: statementFetchable?.idForStatements ?? "")
                case .account:
                    return self.repository.getAccountStatement()
                case .wallet:
                    return self.repository.getAccountStatement()
                }
                
        }
        .share()
        .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
        
        cardStatementRequest.errors().subscribe(onNext: { [unowned self] in self.errorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
        
        let statements = cardStatementRequest.elements().unwrap()
            .map { $0.sorted{ $0.date > $1.date } }
            .map {
                Dictionary(grouping: $0, by: { statement in statement.year }) }
            .map { group in
                group.sorted { lhs, rhs in
                    return Double(lhs.key) ?? 0 > Double(rhs.key) ?? 0 } }
        
        let indexAndStatements = Observable.combineLatest(statements, currentIndexSubject).share()
        
        indexAndStatements.map { $0.1 < $0.0.count-1}.bind(to: decrementEnabledSubject).disposed(by: disposeBag)
        currentIndexSubject.map { $0 > 0}.bind(to: incrementEnabledSubject).disposed(by: disposeBag)
        
        //figure out cardType if statementFetchable is .card
        var cardType: String? = nil
        if let card = statementFetchable as? PaymentCard {
            cardType = card.cardType.localizedString
        }
        
        indexAndStatements
            .filter { $0.0.count > 0}
            .map { $0.0[$0.1].value }
            .map { $0.map { [unowned self] in
                let viewModel = StatementMonthTableViewCellViewModel($0)
                viewModel.outputs.viewStatement.map {
                    EmailStatement(url: URL(string: $0.url), month: $0.month, year: $0.year, statementType: statementFetchable?.statementType.type, cardType: cardType )}.unwrap().bind(to: self.viewStatementSubject).disposed(by: self.disposeBag)
                return viewModel } }
            .map { [SectionModel(model: 0, items: $0)] }
            .bind(to: dataSourceSubject)
            .disposed(by: disposeBag)
        
        indexAndStatements
            .filter { $0.0.count == 0}
            .map { _ in [SectionModel(model: 0, items: [NoStatementCellViewModel()])]  }
            .bind(to: dataSourceSubject)
            .disposed(by: disposeBag)
        
        indexAndStatements
            .filter { $0.0.count > 0}
            .map { $0.0[$0.1].key }
            .bind(to: yearSubject)
            .disposed(by: disposeBag)
        
        decrementYearSubject.withLatestFrom(currentIndexSubject).map { $0 + 1 }.bind(to: currentIndexSubject).disposed(by: disposeBag)
        
        incrementYearSubject.withLatestFrom(currentIndexSubject).map { $0 - 1 }.bind(to: currentIndexSubject).disposed(by: disposeBag)
        
    }
    
    func fetchCustomDateStatements(statementFetchable: StatementFetchable?) {
        let cardStatementRequest = customDateRefreshSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
                .flatMap { [unowned self] rangeSelected -> Observable<Event<Statement?>> in
                    return self.repository.getCustomCardStatement(serialNumber: statementFetchable?.idForStatements ?? "", startDate: rangeSelected.0, endDate: rangeSelected.1)
                }
                .share()
                .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
        
        cardStatementRequest.errors().subscribe(onNext: { [unowned self] in self.errorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
        
        cardStatementRequest.elements().unwrap()
                    .subscribe(onNext: { statement in
                        print(statement.month)
                        print(statement.year)
                        print(statement.url)
                    })
                    .disposed(by: disposeBag)
    }
}

fileprivate extension StatementType {
    var viewTitle: String {
        switch self {
        case .account:
            return "Account statements"
        case .card:
            return "screen_card_statements_display_text_title".localized
        case .wallet:
            return "Wallet statements"
        }
    }
    
    var type: String {
        switch self {
        case .account:
            return "EMAIL_ME_ACCOUNT"
        case .card:
            return "EMAIL_ME_CARD"
        case .wallet:
            return "EMAIL_ME_ACCOUNT"
        }
    }
}

