//
//  CardAnalyticsViewModel.swift
//  YAP
//
//  Created by Zain on 20/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

//import AppAnalytics
import Foundation
import RxSwift
import YAPComponents
import YAPCore
import UIKit
import RxDataSources
import RxTheme
import RxRelay

protocol CardAnalyticsViewModelInput {
//    var backObserver: AnyObserver<Void> { get }
//    var nextObserver: AnyObserver<Void> { get }
    var didSelectDate: AnyObserver<Date> { get }
    var closeObserver: AnyObserver<Void> { get }
    var selectedTabObserver: AnyObserver<Int> { get }
    var selectedCategoryObserver: AnyObserver<Int> { get }
    var selectedCategoryNameObserver: AnyObserver<String?> { get }
    var selectedAnalyticDataObeserver: AnyObserver<(AnalyticsData, AnalyticsDataType, UIColor)> { get }
}

protocol CardAnalyticsViewModelOutput {
    var currency: Observable<String?> { get }
//    var month: Observable<String?> { get }
//    var monthly: Observable<String?> { get }
//    var weekly: Observable<String?> { get }
    var amount: Observable<String?> { get }
//    var nextEnabled: Observable<Bool> { get }
//    var backEnabled: Observable<Bool> { get }
    var average: Observable<NSAttributedString?> { get }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var selectedTab: Observable<Int> { get }
    var close: Observable<Void> { get }
    var pieChartData: Observable<[PieChartComponent]> { get }
    var selectedCategory: Observable<Int> { get }
    var selectionEnabled: Observable<Bool> { get }
    var categoryIcon: Observable<((String?, UIImage?), AnalyticsDataType)> { get }
    var categoryTitle: Observable<String?> { get }
    var categoryAmount: Observable<String?> { get }
    var categoryColor: Observable<UIColor> { get }
    var percentage: Observable<String?> { get }
    var type: Observable<AnalyticsDataType> { get }
    var showError: Observable<String> { get }
    var selectedAnalyticData: Observable<(AnalyticsData, AnalyticsDataType, UIColor, Date)> { get }
    var mode: Observable<UIImageView.ContentMode> { get }
    var selectedCategoryName: Observable<String?> { get }
    var userAllowedToInteract: Observable<Bool> {get}
    var selectedIndex: Observable<Int> {get}
    var months: Observable<[MonthCollectionViewCellViewModel]> {get}
    var selectedDate: Observable<Date> {get}
    
}

protocol CardAnalyticsViewModelType {
    var inputs: CardAnalyticsViewModelInput { get }
    var outputs: CardAnalyticsViewModelOutput { get }
}

class CardAnalyticsViewModel: CardAnalyticsViewModelType, CardAnalyticsViewModelInput, CardAnalyticsViewModelOutput {
    
    
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: CardAnalyticsViewModelInput { return self }
    var outputs: CardAnalyticsViewModelOutput { return self }
    
//    private let backSubject = PublishSubject<Void>()
//    private let nextSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    
    private let currencySubject = BehaviorSubject<String?>(value: nil)
    private let monthSubject = BehaviorSubject<String?>(value: nil)
    private let amountSubject = BehaviorSubject<String?>(value: nil)
    private let nextEnabledSubject = BehaviorSubject<Bool>(value: false)
    private let backEnabledSubject = BehaviorSubject<Bool>(value: true)
    private let averageSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let selectedTabSubject = BehaviorSubject<Int>(value: 0)
    private let pieChartDataSubject: BehaviorSubject<[PieChartComponent]>
    private let selectedCategorySubject = BehaviorSubject<Int>(value: 0)
    private let analytics = BehaviorSubject<Analytics>(value: Analytics.empty)
    private let selectionEnabledSubject = BehaviorSubject<Bool>(value: true)
    private let categoryIconSubject = BehaviorSubject<((String?, UIImage?), AnalyticsDataType)>(value: ((nil, nil), .category))
    private let categoryTitleSubject = BehaviorSubject<String?>(value: nil)
    private let categoryAmountSubject = BehaviorSubject<String?>(value: nil)
    private let categoryColorSubject = BehaviorSubject<UIColor>(value: .white)
    private let percentageSubject = BehaviorSubject<String?>(value: nil)
    private let typeSubject = BehaviorSubject<AnalyticsDataType>(value: .category)
    private let showErrorSubject = PublishSubject<String>()
    private let selectedCategoryNameSubject = PublishSubject<String?>()
    private let selectedAnalyticsDataSubject = PublishSubject<(AnalyticsData, AnalyticsDataType, UIColor)>()
    private let merchantCategoryAnalyticsSubject = PublishSubject<(AnalyticsData, AnalyticsDataType, UIColor, Date)>()
    private let modeSubject = BehaviorSubject<UIImageView.ContentMode>(value: .center)
    private let userAllowedToInteractSubject = BehaviorSubject<Bool>(value: true)
    private let selectedIndexSubject = BehaviorSubject<Int>(value: 0)
    private let dateSubject = BehaviorSubject<Date>(value: Date().startOfMonth)
    
    // MARK: - Inputs
//    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
//    var nextObserver: AnyObserver<Void> { return nextSubject.asObserver() }
//    var selectedDate: AnyObserver<Date> { return dateSubject.asObserver() }
    var didSelectDate: AnyObserver<Date> {dateSubject.asObserver()}
    var closeObserver: AnyObserver<Void> { return closeSubject.asObserver() }
    var selectedTabObserver: AnyObserver<Int> { return selectedTabSubject.asObserver() }
    var selectedCategoryObserver: AnyObserver<Int> { return selectedCategorySubject.asObserver() }
    var selectedAnalyticDataObeserver: AnyObserver<(AnalyticsData, AnalyticsDataType, UIColor)> { selectedAnalyticsDataSubject.asObserver() }
    var selectedCategoryNameObserver: AnyObserver<String?> { return selectedCategoryNameSubject.asObserver() }
    
    // MARK: - Outputs
    var currency: Observable<String?> { return currencySubject.asObservable() }
//    var monthly: Observable<String?> { return monthlySubject.asObservable() }
    var weekly: Observable<String?> { return Observable.of("Weekly") }
    var month: Observable<String?> { return monthSubject.asObservable() }
    var amount: Observable<String?> { return amountSubject.asObservable() }
    var nextEnabled: Observable<Bool> { return nextEnabledSubject.asObservable() }
    var backEnabled: Observable<Bool> { return backEnabledSubject.asObservable() }
    var average: Observable<NSAttributedString?> { return averageSubject.asObservable() }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var selectedTab: Observable<Int> { return selectedTabSubject.asObservable() }
    var close: Observable<Void> { return closeSubject.asObservable() }
    var pieChartData: Observable<[PieChartComponent]> { return pieChartDataSubject.asObservable() }
    var selectedCategory: Observable<Int> { return selectedCategorySubject.asObservable() }
    var selectionEnabled: Observable<Bool> { return selectionEnabledSubject.asObservable() }
    var categoryIcon: Observable<((String?, UIImage?), AnalyticsDataType)> { return categoryIconSubject.asObservable() }
    var categoryTitle: Observable<String?> { return categoryTitleSubject.asObservable() }
    var categoryAmount: Observable<String?> { return categoryAmountSubject.asObservable() }
    var categoryColor: Observable<UIColor> { return categoryColorSubject.asObservable() }
    var percentage: Observable<String?> { return percentageSubject.asObservable() }
    var type: Observable<AnalyticsDataType> { return typeSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var selectedAnalyticData: Observable<(AnalyticsData, AnalyticsDataType, UIColor, Date)> { merchantCategoryAnalyticsSubject.asObservable() }
    var selectedCategoryName: Observable<String?> { return selectedCategoryNameSubject.asObservable() }
    var mode: Observable<UIView.ContentMode> { modeSubject.asObservable() }
    var userAllowedToInteract: Observable<Bool> {userAllowedToInteractSubject}
    var selectedIndex: Observable<Int> {selectedIndexSubject}
    let months: Observable<[MonthCollectionViewCellViewModel]>
    var selectedDate: Observable<Date> { dateSubject.asObservable()}
    
    private let formatter = DateFormatter()
    private let repository: AnalyticsRepositoryType
    private typealias AllAnalytics = (categoryAnalytics: Analytics, merchantAnalytics: Analytics)
    private var analyticsData: [Date: AllAnalytics] = [:]
    private var card: PaymentCard
    private var currentTab = 0
    private var currentDate = Date().startOfMonth
//    private let monthlySubject = BehaviorSubject<String?>(value: nil)
    private var defaultColor: UIColor?
    
    // MARK: - Init
    init(repository: AnalyticsRepositoryType,themeService: ThemeService<AppTheme>, card: PaymentCard, accountCreatedDate: Observable<Date>, date: Date? = nil) {
        
//        AppAnalytics.shared.logEvent(CardEvent.cardAnalyticsOpened())
        self.repository = repository
        self.card = card
        pieChartDataSubject = BehaviorSubject<[PieChartComponent]>(value: [PieChartComponent(number: 1, color: UIColor(themeService.attrs.greyLight))])
        
        formatter.dateFormat = "MMMM, yyyy"
        currencySubject.onNext("AED")
        
        months = analytics.withLatestFrom(accountCreatedDate) { data, accountCreatedDate in
//            let startDate = accountCreatedDate
            let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: startDate)
            let startOfMonth = Calendar.current.date(from: comp)!
            let currentYear = Calendar.current.dateComponents([.year], from: Date()).year ?? 0
            var dates = [Date]()
            dates.append(startOfMonth)
            
            var endOfYearReached = false
            var previousDate = startOfMonth
            while(!endOfYearReached) {
                
                // get next date, while next date is less than or equal to current year add it to list
                if let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: previousDate),
                   let year = Calendar.current.dateComponents([.year], from: nextDate).year,
                   year <= currentYear {
                    dates.append(nextDate)
                    previousDate = nextDate
                }else {
                    endOfYearReached = true
                }
            }
            
            var index = -1
            return dates.map{
                index += 1
                return MonthCollectionViewCellViewModel(date: $0, isFirstItem: index == 0, isLastItem: index == dates.count-1)
            }
        }

        /*
        months = analytics.map { data -> [MonthCollectionViewCellViewModel] in
           
            let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: data.date)
            let startOfMonth = Calendar.current.date(from: comp)!
            let currentYear = Calendar.current.dateComponents([.year], from: Date()).year ?? 0
            var dates = [Date]()
            dates.append(startOfMonth)
            
            var endOfYearReached = false
            var previousDate = startOfMonth
            while(!endOfYearReached) {
                
                // get next date, while next date is less than or equal to current year add it to list
                if let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: previousDate),
                   let year = Calendar.current.dateComponents([.year], from: nextDate).year,
                   year <= currentYear {
                    dates.append(nextDate)
                    previousDate = nextDate
                }else {
                    endOfYearReached = true
                }
            }
            
            var index = -1
            return dates.map{
                index += 1
                return MonthCollectionViewCellViewModel(date: $0, isFirstItem: index == 0, isLastItem: index == dates.count-1)
            }
        }*/
        
        /*
        analytics.map { [unowned self] in
            if $0.date.isInSameYear(as: Date()) {
                self.formatter.dateFormat = "MMMM"
            } else {
                self.formatter.dateFormat = "MMM yyyy"
            }
            let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: $0.date)
            let startOfMonth = Calendar.current.date(from: comp)!
            let startOfMonthString = self.formatter.string(from: startOfMonth)
            return startOfMonthString
        }.bind(to: monthlySubject).disposed(by: disposeBag)*/
        
        analytics.subscribe(onNext: {[weak self] in
            self?.currentDate = $0.date
            self?.selectionEnabledSubject.onNext($0.analytics.count > 0)
            guard $0.analytics.count > 0 else { return }
            self?.selectedCategorySubject.onNext(0)
        }).disposed(by: disposeBag)
        
        analytics.map { $0.date < Date().startOfMonth }.bind(to: nextEnabledSubject).disposed(by: disposeBag)
        
        Observable.combineLatest(analytics.map { $0.date }, accountCreatedDate.map{$0.startOfMonth}).map { $0.0 > $0.1 }.bind(to: backEnabledSubject).disposed(by: disposeBag)
        
//        let backDate = backSubject.withLatestFrom(analytics.map { $0.date }).map { $0.date(byAddingMonths: -1) }
//        let nextDate = nextSubject.withLatestFrom(analytics.map { $0.date }).map { $0.date(byAddingMonths: 1) }
        
        /*
        Observable.merge(backDate, nextDate).startWith(date?.startOfMonth ??  Date().startOfMonth).subscribe(onNext: { [weak self] in
            self?.fetchData(forDate: $0)
//            AppAnalytics.shared.logEvent(AnalyticsEvent.dateScrolled())
        }).disposed(by: disposeBag)*/
        dateSubject.subscribe(onNext: { [weak self] in
            self?.fetchData(forDate: $0)
//            AppAnalytics.shared.logEvent(AnalyticsEvent.dateScrolled())
        }).disposed(by: disposeBag)
        
        selectedTabSubject.subscribe(onNext: { [weak self] tag in
            self?.currentTab = tag
//            tag == 0 ? AppAnalytics.shared.logEvent(AnalyticsEvent.categoryTapped()) : AppAnalytics.shared.logEvent(AnalyticsEvent.merchantTapped())
            tag == 0 ? self?.userAllowedToInteractSubject.onNext(true) : self?.userAllowedToInteractSubject.onNext(false)
        }).disposed(by: disposeBag)
        
        selectedTabSubject.map { [unowned self] in $0 == 0 ? self.analyticsData[self.currentDate]?.categoryAnalytics : self.analyticsData[self.currentDate]?.merchantAnalytics}.unwrap().bind(to: analytics).disposed(by: disposeBag)
        
        analytics.map { CurrencyFormatter.formatAmountInLocalCurrency($0.totalAmount) }.bind(to: amountSubject).disposed(by: disposeBag)
        
        analytics
            .map { analyticsData -> NSAttributedString in
                let amountText = CurrencyFormatter.formatAmountInLocalCurrency(analyticsData.monthlyAverage)
                let text = String.init(format: "screen_card_analytics_display_text_monthly_average".localized, amountText)
                let attribute = NSMutableAttributedString(string: text)
                
                attribute.addAttributes([.foregroundColor: UIColor(themeService.attrs.primaryDark)], range: NSRange(location: text.count - amountText.count, length: amountText.count))
                return attribute }
            .bind(to: averageSubject)
            .disposed(by: disposeBag)
        
        let categoryColorFromInt: (Int) -> UIColor = { value -> UIColor in
            switch value {
            case 0:
                return UIColor(themeService.attrs.secondaryMagenta)
            case 1:
                return UIColor(themeService.attrs.secondaryBlue)
            case 2:
                return UIColor(themeService.attrs.secondaryOrange)
            case 3:
                return UIColor(themeService.attrs.secondaryGreen)
            case 4:
                return UIColor(themeService.attrs.primarySoft)
            default:
                return UIColor(hexString: "DBCDFF")!
            }
        }
        
        self.analytics.filter{ $0.analytics.isEmpty }
            .subscribe(onNext: {[weak self] ana in
                var cellViewModels = [ReusableTableViewCellViewModelType]()
                cellViewModels.append(AnalyticsEmptyDataCellViewModel())
                self?.dataSourceSubject.onNext([SectionModel(model: 0, items: cellViewModels)])
            }).disposed(by: disposeBag)
        
        selectedTabSubject.subscribe(onNext: {[unowned self] tab in
            guard let todaysData = analyticsData[self.currentDate] else {return}
            if !(todaysData.categoryAnalytics.analytics.isEmpty) && tab == 1 {
                let data = todaysData.categoryAnalytics.analytics[0]
                categoryIconSubject.onNext(((data.logoUrl, nil),.category))
                categoryTitleSubject.onNext(data.title)
                categoryAmountSubject.onNext(CurrencyFormatter.formatAmountInLocalCurrency(data.spending))
                percentageSubject.onNext(String.init(format: "%0.2f%%", data.percentage))
                self.defaultColor = hexStringToUIColor(hex: self.analyticsData[self.currentDate]?.categoryAnalytics.analytics[0].categoryColor ?? "")
                
                categoryColorSubject.onNext(self.defaultColor ?? UIColor(themeService.attrs.secondaryMagenta))
                self.selectedIndexSubject.onNext(0)
                self.modeSubject.onNext(.scaleAspectFill)
            }
        }).disposed(by: disposeBag)
        
        selectedCategorySubject.filter{[unowned self] _ in self.currentTab == 0 }.bind(to: selectedIndexSubject).disposed(by: disposeBag)

        self.analytics.filter{ !$0.analytics.isEmpty }.map { [unowned self] analytics in
            analytics.analytics.enumerated()
                .map { [unowned self] cat -> ReusableTableViewCellViewModelType in
                    var viewModel = AnalyticsCategoryCellViewModel(category: .empty, themeService: themeService, color: .white, position: 0, type: .category)
                    if currentTab == 0 {
                        viewModel = AnalyticsCategoryCellViewModel(category: cat.1, themeService: themeService, color: hexStringToUIColor(hex: cat.element.categoryColor ?? ""), position: cat.0, type: analytics.type)
                    }
                    else {
                        viewModel = AnalyticsCategoryCellViewModel(category: cat.1, themeService: themeService, color: categoryColorFromInt((cat.0%5)), position: cat.0, type: analytics.type)
                    }
                    self.selectedCategorySubject.filter({ [unowned self] _ in self.currentTab == 0 }).map { cat.0 == $0 }.bind(to: viewModel.inputs.selectedObserver).disposed(by: self.disposeBag)
                    return viewModel } }
            .map { [SectionModel(model: 0, items: $0)] }
            .bind(to: dataSourceSubject)
            .disposed(by: disposeBag)
        
        self.analytics.map { $0.analytics }.subscribe(onNext: { [unowned self] analytics in
            guard let selectedTab = try? self.selectedTabSubject.value(), selectedTab == 0 else { return }
            var components = analytics.enumerated().map { PieChartComponent(number: $0.1.percentage/100.0, color: hexStringToUIColor(hex: $0.1.categoryColor ?? "")) }
            components = components.count > 0 ? components : [PieChartComponent(number: 1, color: categoryColorFromInt(-1))]
            self.pieChartDataSubject.onNext(components)
        }).disposed(by: disposeBag)
        
        let valid = Observable
            .combineLatest(selectedCategorySubject, analytics)
            .filter { $0.0 < $0.1.analytics.count && $0.0 >= 0}
            .map { (category: $0.1.analytics[$0.0], color: self.hexStringToUIColor(hex: $0.1.analytics[$0.0].categoryColor ?? "") ) }
        
        let notValid = Observable
            .combineLatest(selectedCategorySubject, analytics)
            .filter {!($0.0 < $0.1.analytics.count && $0.0 >= 0)}
            .map { _ in (category: AnalyticsData.empty, color: UIColor.clear) }
        
        let selected = Observable.merge(valid, notValid)
        selected.map { [unowned self] _ in self.currentTab == 0 ? .category : .merchant }.bind(to: typeSubject).disposed(by: disposeBag)
        selected.filter {[unowned self] in $0.color != .clear && self.currentTab == 0 }.map { $0.color }.bind(to: categoryColorSubject).disposed(by: disposeBag)
        selected.filter { $0.color == .clear }.map { _ in .clear }.bind(to: categoryColorSubject).disposed(by: disposeBag)
        
        selected.filter { $0.color != .clear }.subscribe(onNext: { [unowned self] (data, color)  in
            if CategoryType.allCases.filter({ (type) -> Bool in
                if type == .other { return false }
                return type.rawValue.lowercased() == data.title.lowercased()
            }).count > 0 {
                if self.currentTab == 0 {
                    let icon = data.icon(type: .category, color: color)
                    categoryIconSubject.onNext(((data.logoUrl, icon), .category))
                    self.modeSubject.onNext(.scaleAspectFill)
                }
            }
            else {
                let icon = data.title.initialsImage(color: color)
                guard let logoURL = data.logoUrl else {return}
#warning ("need to find a better solution to remove jerk of images on switching tabs")
                if (currentTab == 0) && !(isSameURL(logoURL)) {
                    categoryIconSubject.onNext(((data.logoUrl, icon), .category))
                    self.modeSubject.onNext(.scaleAspectFill)
                }
            }
            }).disposed(by: disposeBag)
        
        selected.filter { $0.color != .clear }.subscribe(onNext: { [unowned self] data, color in
            if currentTab == 0 {
                categoryTitleSubject.onNext(data.title)
                categoryAmountSubject.onNext(CurrencyFormatter.formatAmountInLocalCurrency(data.spending))
                percentageSubject.onNext(String.init(format: "%0.2f%%", data.percentage))
            }
        }).disposed(by: disposeBag)
        
        
        
        selected.filter { $0.color == .clear }.subscribe(onNext: { [unowned self] data, color in
            self.categoryAmountSubject.onNext(nil)
            self.percentageSubject.onNext(nil)
            self.categoryTitleSubject.onNext(nil)
            self.categoryIconSubject.onNext(((nil, nil), .category))
        }).disposed(by: disposeBag)
        
        closeSubject.subscribe(onNext: { _ in YAPProgressHud.hideProgressHud() }).disposed(by: disposeBag)
        
        selectedAnalyticsDataSubject.subscribe(onNext: { [weak self] (data, type, color) in
            self?.merchantCategoryAnalyticsSubject.onNext((data, type, color, self?.currentDate ?? Date()))
        }).disposed(by: disposeBag)
        
        selectedCategoryNameSubject.subscribe(onNext: { catName in
//            AppAnalytics.shared.logEvent(AnalyticsEvent.categoryListTapped(["spend_category":catName ?? ""]))
            }).disposed(by: disposeBag)
    }
    
    func isSameURL(_ url: String)-> Bool {
        guard let firstURL = try? categoryIconSubject.value() else {return false}
        if firstURL.0.0 == url {
            return true
        }
        return false
    }
}

private extension CardAnalyticsViewModel {
    func fetchData(forDate date: Date) {
        
        if let analytics = analyticsData[date] {
            self.analytics.onNext(currentTab == 0 ? analytics.categoryAnalytics : analytics.merchantAnalytics)
            return
        }
        
        YAPProgressHud.showProgressHud()
        
        let categoryRequest = repository.analyticsByCategory(date, self.card.cardSerialNumber ?? "").share()
        let merchantRequest = repository.analyticsByMerchant(date, self.card.cardSerialNumber ?? "").share()
        
        Observable.combineLatest(categoryRequest.map { _ in }, merchantRequest.map { _ in }).subscribe(onNext: { _ in YAPProgressHud.hideProgressHud() }).disposed(by: disposeBag)
        
        Observable.merge(categoryRequest.errors(), merchantRequest.errors()).subscribe(onNext: { [unowned self] in
            self.showErrorSubject.onNext($0.localizedDescription)
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(categoryRequest.elements(), merchantRequest.elements()).subscribe(onNext: { [unowned self] in
            
            var catAnalytics = $0.0 ?? Analytics.empty(withDate: date)
            var merAnalytics = $0.1 ?? Analytics.empty(withDate: date)
            
            catAnalytics.type = .category
            merAnalytics.type = .merchant
            
            self.analyticsData[date] = AllAnalytics(categoryAnalytics: catAnalytics, merchantAnalytics: merAnalytics)
            if self.analyticsData[date]?.categoryAnalytics.analytics.count ?? 0 > 0 {
            self.defaultColor = hexStringToUIColor(hex: self.analyticsData[date]?.categoryAnalytics.analytics[0].categoryColor ?? "")
            }
            self.analytics.onNext(self.currentTab == 0 ? catAnalytics : merAnalytics)
        }).disposed(by: disposeBag)
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
           return UIColor.init(hexString: "DBCDFF")
        }
    }
}*/

extension Date {

    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
   
}
