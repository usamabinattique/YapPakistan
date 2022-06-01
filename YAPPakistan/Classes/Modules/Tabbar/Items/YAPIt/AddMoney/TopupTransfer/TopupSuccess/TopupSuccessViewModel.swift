//
//  TopupSuccessViewModel.swift
//  YAP
//
//  Created by Wajahat Hassan on 11/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol TopupSuccessViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
}

protocol TopupSuccessViewModelOutputs {
    var back: Observable<Void> { get }
    var cardImage: Observable<UIImage?> { get }
    var cardTitle: Observable<String?> { get }
    var cardNumber: Observable<String?> { get }
    var successMessage: Observable<NSAttributedString?> { get }
    var accountBalanceTitle: Observable<String?> { get }
    var balance: Observable<String?> { get }
    var sucessImage: Observable<UIImage?> { get }
    var screenTitle: Observable<String?> { get }
    var dashboardButtonTitle: Observable<String?> { get }
}

protocol TopupSuccessViewModelType {
    var inputs: TopupSuccessViewModelInputs { get }
    var outputs: TopupSuccessViewModelOutputs { get }
}

class TopupSuccessViewModel: TopupSuccessViewModelType, TopupSuccessViewModelInputs, TopupSuccessViewModelOutputs {
    
    let disposeBag = DisposeBag()
    
    var inputs: TopupSuccessViewModelInputs { return self}
    var outputs: TopupSuccessViewModelOutputs { return self }
    
    private let backSubject = PublishSubject<Void>()
    private let cardImageSubject = BehaviorSubject<UIImage?>(value: nil)
    private let cardTitleSubject = BehaviorSubject<String?>(value: nil)
    private let cardNumberSubject = BehaviorSubject<String?>(value: nil)
    private let successMessageSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let accountBalanceTitleSubject = BehaviorSubject<String?>(value: nil)
    private let balanceSubject = BehaviorSubject<String?>(value: nil)
    private let successImageSubject = BehaviorSubject<UIImage?>(value: nil)
    private let screenTitleSubject = BehaviorSubject<String?>(value: nil)
    private let dashboardButtonTitleSubject = BehaviorSubject<String?>(value: nil)
    
    // MARK: - Inputs
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    
    // MARK: - Outputs
    var back: Observable<Void> { return backSubject.asObservable() }
    var cardImage: Observable<UIImage?> { return cardImageSubject.asObservable() }
    var cardTitle: Observable<String?> { return cardTitleSubject.asObservable() }
    var cardNumber: Observable<String?> { return cardNumberSubject.asObservable() }
    var successMessage: Observable<NSAttributedString?> { return successMessageSubject.asObservable() }
    var accountBalanceTitle: Observable<String?> { return accountBalanceTitleSubject.asObservable() }
    var balance: Observable<String?> { return balanceSubject.asObservable() }
    var sucessImage: Observable<UIImage?> { return successImageSubject.asObservable() }
    var screenTitle: Observable<String?> { return screenTitleSubject.asObservable() }
    var dashboardButtonTitle: Observable<String?> { return dashboardButtonTitleSubject.asObservable() }
    
    init(amount: Double, currency: String, card: ExternalPaymentCard, doneButtonTitle: String?, newBalance: String) {
        
        screenTitleSubject.onNext("screen_topup_success_display_text_title".localized)
        cardImageSubject.onNext(card.cardImage())
        cardTitleSubject.onNext(card.nickName)
        cardNumberSubject.onNext(card.maskedNumber)
        successMessageSubject.onNext(makeSuccessMessage(balance: amount, currency: currency))
        accountBalanceTitleSubject.onNext("screen_topup_success_display_text_account_balance_title".localized)
        balanceSubject.onNext(newBalance)
        successImageSubject.onNext(UIImage(named: "icon_completion", in: .yapPakistan))
        dashboardButtonTitleSubject.onNext(doneButtonTitle ?? "screen_topup_success_display_text_dashboard_action_button_title".localized)
    }
    
}

extension TopupSuccessViewModel {
    func makeSuccessMessage(balance: Double, currency: String = "PKR") -> NSMutableAttributedString {
        
        let currentyText = CurrencyFormatter.format(amount: balance, in: currency)
        let attributedString = NSMutableAttributedString(string: String(format: "screen_topup_success_display_text_success_transaction_message".localized, currentyText), attributes: [
            .font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
            .foregroundColor: UIColor(Color(hex: "#9391B1"))
        ])
        
        attributedString.addAttribute(.foregroundColor, value: UIColor(Color(hex: "#272262")), range: (attributedString.string as NSString).range(of: currentyText))
        
        return attributedString
    }
}
