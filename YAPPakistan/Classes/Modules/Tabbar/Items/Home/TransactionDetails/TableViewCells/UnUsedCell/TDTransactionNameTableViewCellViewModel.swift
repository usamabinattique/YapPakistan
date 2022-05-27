//
//  TDTransactionNameTableViewCellViewModel.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 14/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxTheme

protocol TDTransactionNameTableViewCellViewModelInputs {
    
}

protocol TDTransactionNameTableViewCellViewModelOutputs {
    var transactionLogo: Observable<(url: String?, initails: UIImage?)> { get }
    var vendorName: Observable<String?> { get }
    var amount: Observable<String?> { get }
    var location: Observable<String?> { get }
    var currencySymbol: Observable<String?> { get }
    var descriptionImage: Observable<(url: String?, initails: UIImage?)> { get }
    var descriptionLabel: Observable<String?> { get }
}

protocol TDTransactionNameTableViewCellViewModelType {
    var inputs: TDTransactionNameTableViewCellViewModelInputs { get }
    var outputs: TDTransactionNameTableViewCellViewModelOutputs { get }
}

class TDTransactionNameTableViewCellViewModel: TDTransactionNameTableViewCellViewModelType, ReusableTableViewCellViewModelType, TDTransactionNameTableViewCellViewModelInputs, TDTransactionNameTableViewCellViewModelOutputs {
    
    let disposeBag = DisposeBag()
    var reusableIdentifier: String { return TDTransactionNameTableViewCell.defaultIdentifier }
    
    var inputs: TDTransactionNameTableViewCellViewModelInputs { return self}
    var outputs: TDTransactionNameTableViewCellViewModelOutputs { return self }
    
    private let vendorNameSubject: BehaviorSubject<String?>
    private let amountSubject: BehaviorSubject<String?>
    private let locationSubject: BehaviorSubject<String?>
    private let currencySymbolSubject: BehaviorSubject<String?>
    private let descriptionImageSubject: BehaviorSubject<(url: String?, initails: UIImage?)>
    private let descriptionLabelSubject: BehaviorSubject<String?>
    private let transactionLogoSublect: BehaviorSubject<(url: String?, initails: UIImage?)>
    
    // MARK: - inputs
    
    // MARK: - output
    var transactionLogo: Observable<(url: String?, initails: UIImage?)> { return transactionLogoSublect.asObservable() }
    var vendorName: Observable<String?> { return vendorNameSubject.asObservable() }
    var amount: Observable<String?> { return amountSubject.asObservable() }
    var location: Observable<String?> { return locationSubject.asObservable() }
    var currencySymbol: Observable<String?> { return currencySymbolSubject.asObservable() }
    var descriptionImage: Observable<(url: String?, initails: UIImage?)> { return descriptionImageSubject.asObservable() }
    var descriptionLabel: Observable<String?> { return descriptionLabelSubject.asObservable() }
    
    
    public init(vendorName: String, amount: String, location: String, currencySymbol: String, descriptionImage: String, descriptionLabel: String, transactionLogo: String?, themeService: ThemeService<AppTheme>) {
        transactionLogoSublect = BehaviorSubject(value: (transactionLogo, vendorName.initialsImage(backgroundColor: UIColor(themeService.attrs.primary).withAlphaComponent(0.3)/*UIColor.initials.withAlphaComponent(0.3)*/, textColor: UIColor(themeService.attrs.primaryDark))))
        vendorNameSubject = BehaviorSubject(value: vendorName)
        amountSubject = BehaviorSubject(value: amount)
        locationSubject = BehaviorSubject(value: location)
        currencySymbolSubject = BehaviorSubject(value: currencySymbol)
        descriptionImageSubject = BehaviorSubject(value: (descriptionImage, vendorName.initialsImage(backgroundColor: UIColor(themeService.attrs.primary).withAlphaComponent(0.3), textColor: UIColor(themeService.attrs.primaryDark))))
        descriptionLabelSubject = BehaviorSubject(value: descriptionLabel)
    }
}
