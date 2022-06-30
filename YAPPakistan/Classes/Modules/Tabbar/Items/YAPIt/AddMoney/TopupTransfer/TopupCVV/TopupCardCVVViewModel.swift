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
    var backObserver: AnyObserver<Void> { get }
}

protocol TopupCardCVVViewModelOutput {
    var cardImage: Observable<UIImage?> { get }
    var cardTitle: Observable<String?> { get }
    var cardNumber: Observable<String?> { get }
    var cvvCount: Observable<Int> { get }
    var amount: Observable<NSAttributedString?> { get }
    var error: Observable<String> { get }
    var result: Observable<String> { get }
    var confirmEnabled: Observable<Bool> { get }
    var back: Observable<Void> { get }
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
    var accountBalance = ""
    
    private let cvvSubject = ReplaySubject<String?>.create(bufferSize: 1)
    private let confirmSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    private let accountBalanceSubject = BehaviorSubject<String?>(value: nil)
    
    private let cardImageSubject: BehaviorSubject<UIImage?>
    private let cardTitleSubject: BehaviorSubject<String?>
    private let cardNumberSubject: BehaviorSubject<String?>
    private let cvvCountSubject: BehaviorSubject<Int>
    private let amountSubject: BehaviorSubject<NSAttributedString?>
    private let errorSubject = PublishSubject<String>()
    private let resultSubject = PublishSubject<String>()
    private let confirmEnabledSubject = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Inputs
    var cvvObserver: AnyObserver<String?> { return cvvSubject.asObserver() }
    var confirmObserver: AnyObserver<Void> { return confirmSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    
    // MARK: - Outputs
    var cardImage: Observable<UIImage?> { return cardImageSubject.asObservable() }
    var cardTitle: Observable<String?> { return cardTitleSubject.asObservable() }
    var cardNumber: Observable<String?> { return cardNumberSubject.asObservable() }
    var amount: Observable<NSAttributedString?> { return amountSubject.asObservable()}
    var cvvCount: Observable<Int> { return cvvCountSubject.asObservable() }
    var error: Observable<String> { return errorSubject.asObservable() }
    var result: Observable<String> { return resultSubject.asObservable() }
    var confirmEnabled: Observable<Bool> { return confirmEnabledSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    
    private let repository: TransactionsRepository
    
    // MARK: - Init
    init(card: ExternalPaymentCard, amount: Double, currency: String, orderID: String, repository: TransactionsRepository) {
        
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
        
        /*confirmSubject
            .subscribe(onNext:{ [unowned self] _ in
                self.cvvSubject.unwrap().bind(to: resultSubject).disposed(by: disposeBag)
            }).disposed(by: disposeBag) */
        
        confirmSubject.flatMap{ [unowned self] in self.cvvSubject }
            .subscribe(onNext:{ cv in
                print(cv)
                if let cvv = cv {
                    self.resultSubject.onNext(cvv)
                }
            }).disposed(by: disposeBag)
            //.unwrap().bind(to: resultSubject).disposed(by: disposeBag)
        
        backSubject.subscribe(onNext: { [weak self] in self?.resultSubject.onCompleted() }).disposed(by: disposeBag)
        
        cvvSubject.unwrap().map { $0.count == (card.type == .americanExpress ? 4 : 3) }.bind(to: confirmEnabledSubject).disposed(by: disposeBag)
    }
    
}
