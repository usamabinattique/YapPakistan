//
//  SMFTConvertedAmountInputCellViewModel.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol SMFTConvertedAmountInputCellViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var conversionRate: AnyObserver<String> { get }
}

protocol SMFTConvertedAmountInputCellViewModelOutput {
    var text: Observable<String?> { get }
    var currency: Observable<String?> { get }
    var rate: Observable<NSAttributedString?> { get }
}

protocol SMFTConvertedAmountInputCellViewModelType {
    var inputs: SMFTConvertedAmountInputCellViewModelInput { get }
    var outputs: SMFTConvertedAmountInputCellViewModelOutput { get }
}

class SMFTConvertedAmountInputCellViewModel: SMFTConvertedAmountInputCellViewModelType, SMFTConvertedAmountInputCellViewModelInput, SMFTConvertedAmountInputCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SMFTConvertedAmountInputCellViewModelInput { return self }
    var outputs: SMFTConvertedAmountInputCellViewModelOutput { return self }
    var reusableIdentifier: String { return SMFTConvertedAmountInputCell.defaultIdentifier }
    
    private let textSubject = BehaviorSubject<String?>(value: nil)
    private let currencySubject = BehaviorSubject<String?>(value: nil)
    private let rateSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let conversionRateSubject = PublishSubject<String>()
    
    // MARK: - Inputs
    var textObserver: AnyObserver<String?> { return textSubject.asObserver() }
    var conversionRate: AnyObserver<String> { return conversionRateSubject.asObserver() }
    
    // MARK: - Outputs
    var text: Observable<String?> { return textSubject.asObservable() }
    var currency: Observable<String?> { return currencySubject.asObservable() }
    var rate: Observable<NSAttributedString?> { return rateSubject.asObservable() }
    
    // MARK: - Init
    init(currency: String, convertedCurrency: String) {
        
        currencySubject.onNext(currency)
        
        conversionRateSubject.map { rate in
            let titleText = "screen_international_funds_transfer_display_text_yap_rate".localized
            let destination = CurrencyFormatter.format(amount: 1, in: convertedCurrency)
            let source = "\(currency) \(rate)"
            let rateText = "\(destination) to \(source)"
            let text = titleText + rateText
            let attributed = NSMutableAttributedString(string: text)
            attributed.addAttributes([.foregroundColor: UIColor.darkGray], range: (text as NSString).range(of: destination))
            attributed.addAttributes([.foregroundColor: UIColor.darkGray], range: (text as NSString).range(of: source))
            return attributed }
            .bind(to: rateSubject)
            .disposed(by: disposeBag)
    }
}
