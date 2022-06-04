//
//  AnalyticsCategoryCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 16/05/2022.
//

import Foundation
import RxSwift
import RxTheme

protocol AnalyticsCategoryCellViewModelInput {
    var selectedObserver: AnyObserver<Bool> { get }
}

protocol AnalyticsCategoryCellViewModelOutput {
    var color: Observable<(UIColor, AnalyticsDataType)> { get }
    var image: Observable<((String?, UIImage?), AnalyticsDataType)> { get }
    var title: Observable<String?> { get }
    var amount: Observable<String?> { get }
    var transactions: Observable<String?> { get }
    var percentage: Observable<String?> { get }
    var selected: Observable<Bool> { get }
    var type: Observable<AnalyticsDataType> { get }
    var mode: Observable<UIImageView.ContentMode> { get }
    var showLabelInCaseOfNoTransaction: Observable<Bool>{ get }
    var iconBackgroundColor: Observable<UIColor> { get }
}

protocol AnalyticsCategoryCellViewModelType {
    var inputs: AnalyticsCategoryCellViewModelInput { get }
    var outputs: AnalyticsCategoryCellViewModelOutput { get }
}

class AnalyticsCategoryCellViewModel: AnalyticsCategoryCellViewModelType, AnalyticsCategoryCellViewModelInput, AnalyticsCategoryCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: AnalyticsCategoryCellViewModelInput { return self }
    var outputs: AnalyticsCategoryCellViewModelOutput { return self }
    var reusableIdentifier: String { return AnalyticsCategoryCell.defaultIdentifier }
    var data: AnalyticsData!
    var analyticsType: AnalyticsDataType!
    var analyticsColor: UIColor!
    
    private let colorSubject: BehaviorSubject<(UIColor, AnalyticsDataType)>
    private let imageSubject = BehaviorSubject<((String?, UIImage?), AnalyticsDataType)>(value: ((nil, nil), .category))
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let amountSubject = BehaviorSubject<String?>(value: nil)
    private let transactionsSubject = BehaviorSubject<String?>(value: nil)
    private let percentageSubject = BehaviorSubject<String?>(value: nil)
    private let selectedSubject = BehaviorSubject<Bool>(value: false)
    private let typeSubject = BehaviorSubject<AnalyticsDataType>(value: .category)
    private let modeSubject = BehaviorSubject<UIImageView.ContentMode>(value: .center)
    private let showLabelInCaseOfNoTransactionSubject = BehaviorSubject<Bool>(value: false)
    private let iconBackgroundColorSubject = BehaviorSubject<UIColor>(value: .clear)
    
    // MARK: - Inputs
    var selectedObserver: AnyObserver<Bool> { return selectedSubject.asObserver() }
    
    // MARK: - Outputs
    var color: Observable<(UIColor, AnalyticsDataType)> { return colorSubject.asObservable() }
    var image: Observable<((String?, UIImage?), AnalyticsDataType)> { return imageSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    var amount: Observable<String?> { return amountSubject.asObservable() }
    var transactions: Observable<String?> { return transactionsSubject.asObservable() }
    var percentage: Observable<String?> { return percentageSubject.asObservable() }
    var selected: Observable<Bool> { return selectedSubject.asObservable() }
    var type: Observable<AnalyticsDataType> { return typeSubject.asObservable() }
    var mode: Observable<UIView.ContentMode> { return modeSubject.asObservable() }
    var showLabelInCaseOfNoTransaction: Observable<Bool>{ return showLabelInCaseOfNoTransactionSubject.asObservable() }
    var iconBackgroundColor: Observable<UIColor> { return iconBackgroundColorSubject.asObservable() }
    
    var position = 0
    
    // MARK: - Init
    init(category: AnalyticsData, themeService: ThemeService<AppTheme>, color: UIColor, position: Int, type: AnalyticsDataType) {
        self.position = position
        self.data = category
        self.analyticsType = type
        self.analyticsColor = color
        colorSubject = BehaviorSubject<(UIColor, AnalyticsDataType)>(value: (UIColor(themeService.attrs.secondaryMagenta), .category))
        
        typeSubject.onNext(type)
        let icon = data.title.initialsImage(color: color)
        imageSubject.onNext(((data.logoUrl, icon), type))
        modeSubject.onNext(.scaleAspectFit)
        colorSubject.onNext((color, type))
        
        titleSubject.onNext(category.title)
        let amount = CurrencyFormatter.formatAmountInLocalCurrency(category.spending)
        amountSubject.onNext(type == .category ? amount : "- \(amount.amountFromFormattedAmount)")
        transactionsSubject.onNext("\(category.transactions) \(category.transactions == 1 ? "screen_card_analytics_display_text_transaction".localized : "screen_card_analytics_display_text_transactions".localized)")
        percentageSubject.onNext(String.init(format: "%0.2f%%", category.percentage))
    }
}
