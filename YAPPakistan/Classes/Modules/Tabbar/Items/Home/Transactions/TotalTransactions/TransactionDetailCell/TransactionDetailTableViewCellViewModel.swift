//
//  TransactionDetailTableViewCellViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 02/06/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxTheme
import UIKit

protocol TransactionDetailsTableViewCellViewModelInput {
    var selectedObserver: AnyObserver<Bool> { get }
}

protocol TransactionDetailsTableViewCellViewModelOutput {
    var color: Observable<(UIColor, AnalyticsDataType)> { get }
    var image: Observable<((String?, String?,UIImage?), AnalyticsDataType)> { get }
    var title: Observable<String?> { get }
    var amount: Observable<String?> { get }
    var amountColor: Observable<UIColor?> { get }
    var timeDate: Observable<String?> { get }
    var currency: Observable<String?> { get }
    var selected: Observable<Bool> { get }
    var type: Observable<AnalyticsDataType> { get }
    var mode: Observable<UIImageView.ContentMode> { get }
}

protocol TransactionDetailsTableViewCellViewModelType {
    var inputs: TransactionDetailsTableViewCellViewModelInput { get }
    var outputs: TransactionDetailsTableViewCellViewModelOutput { get }
}

class TransactionDetailsTableViewCellViewModel: TransactionDetailsTableViewCellViewModelType, TransactionDetailsTableViewCellViewModelInput, TransactionDetailsTableViewCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TransactionDetailsTableViewCellViewModelInput { return self }
    var outputs: TransactionDetailsTableViewCellViewModelOutput { return self }
    var reusableIdentifier: String { return TransactionDetailTableViewCell.defaultIdentifier }
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
    private let amountColorSubject = BehaviorSubject<UIColor?>(value: UIColor.green)
    
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
    var amountColor: Observable<UIColor?> { return amountColorSubject.asObservable() }
    var mode: Observable<UIView.ContentMode> { modeSubject.asObservable() }
    var color: Observable<(UIColor, AnalyticsDataType)> { return colorSubject.asObservable() }
    
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: - Init
    init(transaction: TransactionResponse, color: UIColor, url: String? = nil, type: AnalyticsDataType = .merchant, themeService: ThemeService<AppTheme>!) {
        self.themeService = themeService
        colorSubject.onNext((UIColor(themeService.attrs.secondaryMagenta), .category))
        
        let title = transaction.receiverName ?? ""
        
        var icon: UIImage?
        var logoUrl = ""
        if transaction.merchantLogoUrl == "" || transaction.merchantLogoUrl == nil {
            logoUrl = transaction.receiverUrl ?? ""
        }
        else {
            logoUrl = transaction.merchantLogoUrl ?? ""
        }
        icon = title.initialsImage(color: color)
        let categoryIcon = type == .category ? url : nil
        imageSubject.onNext(((logoUrl,categoryIcon, icon), type))
        self.modeSubject.onNext(.scaleAspectFit)
        
        let formatter = DateFormatter()
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "hh:mm a"
        let time = formatter.string(from: transaction.date)
        formatter.dateFormat = "dd MMM yyyy"
        let dayMonth = formatter.string(from: transaction.date)
        if title == "" {
            titleSubject.onNext(transaction.receiverName ?? "Unknown")
        }
        else {
            titleSubject.onNext(title)
        }
        
        if transaction.type == .debit {
            amountSubject.onNext("- " + CurrencyFormatter.format(amount: transaction.cardHolderBillingTotalAmount , in: transaction.cardHolderBillingCurrency ?? "PKR").amountFromFormattedAmount)
            amountColorSubject.onNext(UIColor(themeService.attrs.primaryDark))
        }
        else {
            amountSubject.onNext("+ " + CurrencyFormatter.format(amount: transaction.cardHolderBillingTotalAmount , in: transaction.cardHolderBillingCurrency ?? "PKR").amountFromFormattedAmount)
            amountColorSubject.onNext(UIColor(themeService.attrs.secondaryGreen))
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