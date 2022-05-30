//
//  TransactionTabelViewCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 20/05/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxTheme
import UIKit

protocol TransactionTabelViewCellViewModelInput {
    var selectedObserver: AnyObserver<Bool> { get }
}

protocol TransactionTabelViewCellViewModelOutput {
    var color: Observable<(UIColor, AnalyticsDataType)> { get }
    var image: Observable<((String?, String?,UIImage?), AnalyticsDataType)> { get }
    var title: Observable<String?> { get }
    var amount: Observable<String?> { get }
    var timeDate: Observable<String?> { get }
    var currency: Observable<String?> { get }
    var selected: Observable<Bool> { get }
    var type: Observable<AnalyticsDataType> { get }
    var mode: Observable<UIImageView.ContentMode> { get }
}

protocol TransactionTabelViewCellViewModelType {
    var inputs: TransactionTabelViewCellViewModelInput { get }
    var outputs: TransactionTabelViewCellViewModelOutput { get }
}

class TransactionTabelViewCellViewModel: TransactionTabelViewCellViewModelType, TransactionTabelViewCellViewModelInput, TransactionTabelViewCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TransactionTabelViewCellViewModelInput { return self }
    var outputs: TransactionTabelViewCellViewModelOutput { return self }
    var reusableIdentifier: String { return TransactionTableViewCell.defaultIdentifier }
    var data: AnalyticsData!
    var analyticsType: AnalyticsDataType!
    var analyticsColor: UIColor!
    
    private let imageSubject = BehaviorSubject<((String?, String?, UIImage?), AnalyticsDataType)>(value: ((nil, nil,nil), .merchant))
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let amountSubject = BehaviorSubject<String?>(value: nil)
    private let timeDateSubject = BehaviorSubject<String?>(value: nil)
    private let currencySubject = BehaviorSubject<String?>(value: nil)
    private let selectedSubject = BehaviorSubject<Bool>(value: false)
    private let typeSubject = BehaviorSubject<AnalyticsDataType>(value: .category)
    private let modeSubject = BehaviorSubject<UIImageView.ContentMode>(value: .center)
    private let colorSubject = ReplaySubject<(UIColor, AnalyticsDataType)>.create(bufferSize: 1)
    
    // MARK: - Inputs
    var selectedObserver: AnyObserver<Bool> { return selectedSubject.asObserver() }
    
    // MARK: - Outputs
    var image: Observable<((String?, String?, UIImage?), AnalyticsDataType)> { return imageSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    var amount: Observable<String?> { return amountSubject.asObservable() }
    var timeDate: Observable<String?> { return timeDateSubject.asObservable() }
    var currency: Observable<String?> { return currencySubject.asObservable() }
    var selected: Observable<Bool> { return selectedSubject.asObservable() }
    var type: Observable<AnalyticsDataType> { return typeSubject.asObservable() }
    var mode: Observable<UIView.ContentMode> { modeSubject.asObservable() }
    var color: Observable<(UIColor, AnalyticsDataType)> { return colorSubject.asObservable() }
    
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: - Init
    init(transaction: TransactionResponse, color: UIColor, url: String? = nil, type: AnalyticsDataType = .merchant, themeService: ThemeService<AppTheme>!) {
        self.themeService = themeService
        colorSubject.onNext((UIColor(themeService.attrs.secondaryMagenta), .category))
        
        let title = transaction.merchantName ?? ""
        
        var icon: UIImage?
        var logoUrl = ""
        if transaction.merchantLogoUrl == "" {
            logoUrl = transaction.senderUrl ?? ""
        }
        else {
            logoUrl = transaction.receiverUrl ?? ""
        }
        icon = title.components(separatedBy: " ").first?.initialsImage(color: color)
        let categoryIcon = type == .category ? url : nil
        imageSubject.onNext(((logoUrl,categoryIcon, icon), type))
        self.modeSubject.onNext(.scaleAspectFit)
        
        let formatter = DateFormatter()
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "hh:mm a"
        let time = formatter.string(from: transaction.date)
        formatter.dateFormat = "MMM dd"
        let dayMonth = formatter.string(from: transaction.date)
        if title == "" {
            titleSubject.onNext(transaction.receiverName ?? "Unknown")
        }
        else {
            titleSubject.onNext(title)
        }
        
        if transaction.type == .debit {
            amountSubject.onNext("- " + CurrencyFormatter.format(amount: transaction.cardHolderBillingTotalAmount , in: transaction.cardHolderBillingCurrency ?? "AED").amountFromFormattedAmount)
        }
        else {
            amountSubject.onNext(CurrencyFormatter.format(amount: transaction.cardHolderBillingTotalAmount , in: transaction.cardHolderBillingCurrency ?? "AED").amountFromFormattedAmount)
        }
        currencySubject.onNext(transaction.cardHolderBillingCurrency)
        timeDateSubject.onNext(time + "・" + dayMonth)
        colorSubject.onNext((color, type))
        typeSubject.onNext(type)
    }
    
    private func convertToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }
}
