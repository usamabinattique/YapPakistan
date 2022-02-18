//
//  TopupCardCVVViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 18/02/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxTheme

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
    var backObservable: Observable<Void> { get }
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
    var backObservable: Observable<Void> { backSubject.asObservable() }
    
 //   private let repository = PaymentGatewayRepository()
    
    // MARK: - Init
    init(card: ExternalPaymentCard, amount: Double, currency: String, orderID: String, threeDSecureId: String) {
        
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
        
       /* let paymentRequest = confirmSubject.withLatestFrom(cvvSubject).unwrap()
            .do(onNext: { _ in YAPProgressHud.showProgressHud()})
            .flatMap { [unowned self] in
                self.repository.paymentGatewayTopup(orderID: orderID, beneficiaryID: card.id, amount: String(amount), currency: currency, securityCode: $0, threeDSecureID: threeDSecureId) }
            .share()
        
        paymentRequest.errors()
            .do(onNext: { _ in YAPProgressHud.hideProgressHud()})
            .subscribe(onNext:{ [unowned self] in self.errorSubject.onNext($0.localizedDescription) })
            .disposed(by: disposeBag)
        
        paymentRequest.elements()
            .flatMap{ _ in SessionManager.current.refreshBalance() }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud()})
            .subscribe(onNext: { [weak self] _ in self?.resultSubject.onNext((amount: amount, currency: currency, card: card)) })
            .disposed(by: disposeBag) */
        
        backSubject.subscribe(onNext: { [weak self] in self?.resultSubject.onCompleted() }).disposed(by: disposeBag)
        
        //TODO: remove following line
        confirmSubject.subscribe(onNext: { [weak self] _  in
            print("confirm tapped in cvv")
            self?.resultSubject.onNext((amount: 0.0, currency: "PKR", card: ExternalPaymentCard.mock))
            self?.resultSubject.onCompleted()
            
        }).disposed(by: disposeBag)
        
        cvvSubject.unwrap().map { $0.count == (card.type == .americanExpress ? 4 : 3) }.bind(to: confirmEnabledSubject).disposed(by: disposeBag)
    }
}
