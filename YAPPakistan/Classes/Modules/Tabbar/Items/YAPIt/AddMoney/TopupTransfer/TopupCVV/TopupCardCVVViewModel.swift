//
//  TopupCardCVVViewModel.swift
//  YAP
//
//  Created by Zain on 14/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol TopupCardCVVViewModelInput {
    var cvvObserver: AnyObserver<String?> { get }
    var confirmObserver: AnyObserver<Void> { get }
    var back: AnyObserver<Void> { get }
}

protocol TopupCardCVVViewModelOutput {
    var cardImage: Observable<UIImage?> { get }
    var cardTitle: Observable<String?> { get }
    var cardNumber: Observable<String?> { get }
    var cvvCount: Observable<Int> { get }
    var amount: Observable<NSAttributedString?> { get }
    var error: Observable<String> { get }
    var result: Observable<(amount: Double, currency: String, card: ExternalPaymentCard)> { get }
    var confirmEnabled: Observable<Bool> { get }
}

protocol TopupCardCVVViewModelType {
    var inputs: TopupCardCVVViewModelInput { get }
    var outputs: TopupCardCVVViewModelOutput { get }
}

class TopupCardCVVViewModel: TopupCardCVVViewModelType, TopupCardCVVViewModelInput, TopupCardCVVViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TopupCardCVVViewModelInput { return self }
    var outputs: TopupCardCVVViewModelOutput { return self }
    
    private let cvvSubject = PublishSubject<String?>()
    private let confirmSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    
    private let cardImageSubject: BehaviorSubject<UIImage?>
    private let cardTitleSubject: BehaviorSubject<String?>
    private let cardNumberSubject: BehaviorSubject<String?>
    private let cvvCountSubject: BehaviorSubject<Int>
    private let amountSubject: BehaviorSubject<NSAttributedString?>
    private let errorSubject = PublishSubject<String>()
    private let resultSubject = PublishSubject<(amount: Double, currency: String, card: ExternalPaymentCard)>()
    private let confirmEnabledSubject = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Inputs
    var cvvObserver: AnyObserver<String?> { return cvvSubject.asObserver() }
    var confirmObserver: AnyObserver<Void> { return confirmSubject.asObserver() }
    var back: AnyObserver<Void> { return backSubject.asObserver() }
    
    // MARK: - Outputs
    var cardImage: Observable<UIImage?> { return cardImageSubject.asObservable() }
    var cardTitle: Observable<String?> { return cardTitleSubject.asObservable() }
    var cardNumber: Observable<String?> { return cardNumberSubject.asObservable() }
    var amount: Observable<NSAttributedString?> { return amountSubject.asObservable()}
    var cvvCount: Observable<Int> { return cvvCountSubject.asObservable() }
    var error: Observable<String> { return errorSubject.asObservable() }
    var result: Observable<(amount: Double, currency: String, card: ExternalPaymentCard)> { return resultSubject.asObservable() }
    var confirmEnabled: Observable<Bool> { return confirmEnabledSubject.asObservable() }
    
    private let repository: TransactionsRepository
    
    // MARK: - Init
    init(card: ExternalPaymentCard, amount: Double, currency: String, orderID: String, threeDSecureId: String, repository: TransactionsRepository) {
        
        self.repository = repository
        
        cardImageSubject = BehaviorSubject<UIImage?>(value: card.cardImage(withWidth: 100))
        cardTitleSubject = BehaviorSubject<String?>(value: card.nickName)
        cardNumberSubject = BehaviorSubject<String?>(value: card.maskedNumber)
        cvvCountSubject = BehaviorSubject<Int>(value: card.type == .americanExpress ? 4 : 3)
        
        let value = CurrencyFormatter.format(amount: amount, in: currency)
        let title = "screen_topup_card_cvv_display_text_cvv".localized
        let text = "\(title) \(value)"
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttributes([.foregroundColor: UIColor(Color(hex: "#272262"))], range: NSRange(location: text.count - value.count, length: value.count))
        
        amountSubject = BehaviorSubject<NSAttributedString?>(value: attributed)
        
        let paymentRequest = confirmSubject.withLatestFrom(cvvSubject).unwrap()
            .do(onNext: { _ in YAPProgressHud.showProgressHud()})
            .flatMap { [unowned self] in
                self.repository.paymentGatewayTopup(threeDSecureId: threeDSecureId, orderId: orderID, currency: currency, amount: String(amount), sessionId: "", securityCode: $0, beneficiaryId: String(card.id)) }
            .share()
        
        paymentRequest.errors()
            .do(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            })
            .subscribe(onNext:{ [weak self] error in
                self?.errorSubject.onNext(error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        paymentRequest.elements()
            //.flatMap{ _ in SessionManager.current.refreshBalance() }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud()})
            .subscribe(onNext: { [weak self] _ in self?.resultSubject.onNext((amount: amount, currency: currency, card: card)) })
            .disposed(by: disposeBag)
        
        backSubject.subscribe(onNext: { [weak self] in self?.resultSubject.onCompleted() }).disposed(by: disposeBag)
        
        cvvSubject.unwrap().map { $0.count == (card.type == .americanExpress ? 4 : 3) }.bind(to: confirmEnabledSubject).disposed(by: disposeBag)
    }
}
