//
//  MerchantAnalyticsDetailViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 20/05/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxDataSources
import RxTheme
import UIKit

protocol MerchantAnalyticsDetailViewModelInput {
    var closeObserver: AnyObserver<Void> { get }
    var fetchDataObserver: AnyObserver<Void> { get }
}

protocol MerchantAnalyticsDetailViewModelOutput {
    var title: Observable<String?> { get }
    var month: Observable<String?> { get }
    var amount: Observable<String?> { get }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var close: Observable<Void> { get }
    var categoryIcon: Observable<((String?, UIImage?), AnalyticsDataType)> { get }
    var transactionsTitle: Observable<String?> { get }
    var showError: Observable<String> { get }
    var monthlySpend: Observable<String?> { get }
    var vsLastMonth: Observable<String?> { get }
    var averageSpend: Observable<String?> { get }
    var hideOverlayView: Observable<Bool> { get }
    var hideStats: Observable<Bool> { get }
    var color: Observable<(UIColor, AnalyticsDataType)> { get }
    var iconImageMode: Observable<UIImageView.ContentMode> { get }
    var dataType: Observable<AnalyticsDataType> { get }
}

protocol MerchantAnalyticsDetailViewModelType {
    var inputs: MerchantAnalyticsDetailViewModelInput { get }
    var outputs: MerchantAnalyticsDetailViewModelOutput { get }
}

class MerchantAnalyticsDetailViewModel: MerchantAnalyticsDetailViewModelType, MerchantAnalyticsDetailViewModelInput, MerchantAnalyticsDetailViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: MerchantAnalyticsDetailViewModelInput { return self }
    var outputs: MerchantAnalyticsDetailViewModelOutput { return self }
    
    private let closeSubject = PublishSubject<Void>()
    private let monthSubject = BehaviorSubject<String?>(value: nil)
    private let amountSubject = BehaviorSubject<String?>(value: nil)
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let categoryIconSubject = BehaviorSubject<((String?, UIImage?), AnalyticsDataType)>(value: ((nil, nil), .category))
    private let showErrorSubject = PublishSubject<String>()
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let fetchDataSubject = PublishSubject<Void>()
    private let monthlySpendSubject = BehaviorSubject<String?>(value: nil)
    private let vsLastMonthSubject = BehaviorSubject<String?>(value: nil)
    private let averageSpendSubject = BehaviorSubject<String?>(value: nil)
    private let hideOverlayViewSubject = BehaviorSubject<Bool>(value: false)
    private let hideStatsSubject = BehaviorSubject<Bool>(value: true)
    private let colorSubject = ReplaySubject<(UIColor, AnalyticsDataType)>.create(bufferSize: 1)
    private let iconImageModeSubject = BehaviorSubject<UIImageView.ContentMode>(value: .scaleAspectFit)
    private let dataTypeSubject = BehaviorSubject<AnalyticsDataType>(value: .category)
    
    // MARK: - Inputs
    var closeObserver: AnyObserver<Void> { return closeSubject.asObserver() }
    var fetchDataObserver: AnyObserver<Void> { fetchDataSubject.asObserver() }
    
    // MARK: - Outputs
    var month: Observable<String?> { return monthSubject.asObservable() }
    var amount: Observable<String?> { return amountSubject.asObservable() }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var close: Observable<Void> { return closeSubject.asObservable() }
    var categoryIcon: Observable<((String?, UIImage?), AnalyticsDataType)> { return categoryIconSubject.asObservable() }
    var transactionsTitle: Observable<String?> { return Observable.of("Transactions") }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var title: Observable<String?> { titleSubject.asObservable() }
    var monthlySpend: Observable<String?> { monthlySpendSubject.asObservable() }
    var vsLastMonth: Observable<String?> { vsLastMonthSubject.asObservable() }
    var averageSpend: Observable<String?> { averageSpendSubject.asObservable() }
    var hideOverlayView: Observable<Bool> { hideOverlayViewSubject.asObservable() }
    var hideStats: Observable<Bool> { return hideStatsSubject.asObservable() }
    var color: Observable<(UIColor, AnalyticsDataType)> { return colorSubject.asObservable() }
    var iconImageMode: Observable<UIView.ContentMode> { iconImageModeSubject.asObservable() }
    var dataType: Observable<AnalyticsDataType> { dataTypeSubject }
    
    private let formatter = DateFormatter()
    private var repository:  AnalyticsRepositoryType
    private typealias AllAnalytics = (categoryAnalytics: Analytics, merchantAnalytics: Analytics)
    private var analyticsData: [Date: AllAnalytics] = [:]
    private var card: PaymentCard
    private var currentTab = 0
    private var currentDate = Date().startOfMonth
    private let data: AnalyticsData!
    private let type: AnalyticsDataType!
    private let CategorgyColor: UIColor!
    private let date: Date!
    var viewModels: [ReusableTableViewCellViewModelType] = []
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: - Init
    init(repository:  AnalyticsRepositoryType,themeService: ThemeService<AppTheme>!,card: PaymentCard, data: AnalyticsData, type: AnalyticsDataType, color: UIColor, date: Date) {
        self.themeService = themeService
        self.repository = repository
        formatter.dateFormat = "MMMM yyyy"
        self.card = card
        self.data = data
        self.type = type
        self.CategorgyColor = color
        self.date = date
        
        self.colorSubject.onNext((color, type))
        
        titleSubject.onNext(data.title)
        if type == .category {
            if CategoryType.allCases.filter({ (type) -> Bool in
                return type.rawValue.lowercased() == data.title.lowercased()
            }).count > 0 {
                self.iconImageModeSubject.onNext(.scaleAspectFit)
                categoryIconSubject.onNext(((data.logoUrl, data.icon(type: type, color: color)), type))
            } else {
                self.iconImageModeSubject.onNext(.scaleAspectFill)
                categoryIconSubject.onNext(((data.logoUrl, data.title.initialsImage(color: color)), type))
            }
        } else {
            self.iconImageModeSubject.onNext(.scaleAspectFill)
            categoryIconSubject.onNext(((data.logoUrl, data.icon(type: .merchant, color: color)), type))
        }
        
        closeSubject.subscribe(onNext: { _ in YAPProgressHud.hideProgressHud() }).disposed(by: disposeBag)
        let amount = CurrencyFormatter.formatAmountInLocalCurrency(data.spending)
        amountSubject.onNext(amount)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let dateString = formatter.string(from: self.date)
        monthlySpendSubject.onNext(String(data.percentage) + "%")
        monthSubject.onNext(dateString + "・" + String(data.transactions) +  (String(data.transactions>1 ? " transactions":" transaction")))
        
        if type == .merchant {
            fetchDataMerchant(forDate: date)
        } else {
            fetchDataCategory(forDate: date, categoryColor: UIColor(self.themeService.attrs.primary))
        }
        
        if self.data.title.lowercased() == "general".lowercased() {
            self.hideStatsSubject.onNext(true)
        }
        else {
            self.hideStatsSubject.onNext(false)
        }
        
        dataTypeSubject.onNext(type)
    }
}

fileprivate extension MerchantAnalyticsDetailViewModel {
    func fetchDataMerchant(forDate date: Date) {
        let fetchDataRequest = fetchDataSubject.share()
        let result = fetchDataRequest
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap{ [unowned self] bool -> Observable<Event<MerchantCategoryDetail?>> in
                var categories: [String] = []
                if self.data.title.lowercased() == "other".lowercased() {
                    categories = self.data.categories ?? []
                } else {
                    categories = [self.data.title]
                }
               /* return self.repository.fetchMerchantAnalytics(date, self.card.cardSerialNumber ?? "", categories: categories)  */
                return self.repository.fetchMerchantAnalytics(date, self.card.cardSerialNumber ?? "", isMerchantAnalytics: true, filterBy: self.data.title)
        }
        .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
        .share()
        
        result.elements().subscribe(onNext: { [unowned self] (data) in
            self.hideOverlayViewSubject.onNext(true)
            self.loadData(merchantCategoryData: data, type: .merchant)
        }).disposed(by: disposeBag)
        
        result
            .errors().do(onNext: { [weak self] (error) in
                self?.hideOverlayViewSubject.onNext(false)
            })
            .map{ $0.localizedDescription }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)
    }
    
    func fetchDataCategory(forDate date: Date, categoryColor: UIColor) {
        let fetchDataRequest = fetchDataSubject.share()
        let result = fetchDataRequest
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap{ [unowned self] bool -> Observable<Event<MerchantCategoryDetail?>> in
                var categories: [Int?] = []
                categories = [data.categoryId]
                return self.repository.fetchCategorynalytics(date, self.card.cardSerialNumber ?? "", filterBy: String(self.data.categoryId ?? 0))
        }
        .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
        .share()
        
        result.elements().subscribe(onNext: { [unowned self] (data) in
            self.hideOverlayViewSubject.onNext(true)
            self.loadData(merchantCategoryData: data, type: .category)
        }).disposed(by: disposeBag)
        
        result
            .errors().do(onNext: { [weak self] (error) in
                self?.hideOverlayViewSubject.onNext(false)
            })
            .map{ $0.localizedDescription }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)
    }
    
    func loadData(merchantCategoryData: MerchantCategoryDetail?, type: AnalyticsDataType = .merchant) {
        guard let merchantCategoryData = merchantCategoryData else {
            return
        }
        
        let absoluteValue = String(abs(Int(merchantCategoryData.currentToLastMonth) ?? 0))
        let a = Double(merchantCategoryData.currentToLastMonth) ?? 0
        let yesValue = ("-" + String(absoluteValue) + "%")
        let falseValue = ("+" + String(absoluteValue) + "%")
        let vsLastMonth = a < 0.0 ? yesValue : falseValue
        vsLastMonthSubject.onNext(vsLastMonth)
        let averageSpendValue = (Double(merchantCategoryData.averageSpending) ?? 0).formattedAmount(toFractionDigits: 2)
        averageSpendSubject.onNext("\(averageSpendValue)")
        
        let viewModels = merchantCategoryData.transactionDetails.map { (transaction) -> TransactionTabelViewCellViewModel in
            return TransactionTabelViewCellViewModel(transaction: transaction, color: self.CategorgyColor, url: self.data.logoUrl ?? data.logoUrl, type: type, themeService: self.themeService)
        }
        self.dataSourceSubject.onNext([SectionModel(model: 0, items: viewModels)])
    }
}
/*
fileprivate extension Int {
    var categoryColor: UIColor {
        switch self {
        case 0:
            return .secondaryMagenta
        case 1:
            return .secondaryBlue
        case 2:
            return .secondaryOrange
        case 3:
            return .secondaryGreen
        case 4:
            return .primarySoft
        default:
            return .greyLight
        }
    }
}
*/
