//
//  ConfirmCardPinViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 16/11/2021.
//

import RxSwift

protocol ConfirmCardPinViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var nextObserver: AnyObserver<Void> { get }
    var termsObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol ConfirmCardPinViewModelOutputs {
    var next: Observable<String> { get }
    var back: Observable<Void> { get }
    var isPinValid: Observable<Bool> { get }
    var pinCode: Observable<String?> { get }
    var error: Observable<String> { get }
    var terms: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var hideTermsView: Observable<Bool> { get }
    var localizedText: Observable<ConfirmCardPinViewStrings> { get }
}

protocol ConfirmCardPinViewModelType {
    var inputs: ConfirmCardPinViewModelInputs { get }
    var outputs: ConfirmCardPinViewModelOutputs { get }
}

class ConfirmCardPinViewModel: ConfirmCardPinViewModelType, ConfirmCardPinViewModelInputs, ConfirmCardPinViewModelOutputs {

    // MARK: - Properties
    var inputs: ConfirmCardPinViewModelInputs { self }
    var outputs: ConfirmCardPinViewModelOutputs { self }

    // MARK: - Inputs - Implementation of "inputs" protocol
    var keyPressObserver: AnyObserver<String> { keyPressSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var termsObserver: AnyObserver<Void> { termsSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: - Outputs - Implementation of "outputs" protocol
    var isPinValid: Observable<Bool> { isPinValidSubject.asObservable() }
    var pinCode: Observable<String?> { pinCodeSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var terms: Observable<Void> { termsSubject.asObservable() }
    var loader: Observable<Bool> { loaderSubject.asObservable() }
    var next: Observable<String> { nextResultSubject.asObserver() }
    var back: Observable<Void> { backSubject.asObservable() }
    var hideTermsView: Observable<Bool> { hideTermsViewSubject.asObservable() }
    var localizedText: Observable<ConfirmCardPinViewStrings> { localizedTextSubject.asObservable() }

    // MARK: - Subjects
    let nextSubject = PublishSubject<Void>()
    let nextResultSubject = PublishSubject<String>()
    let backSubject = PublishSubject<Void>()
    let isPinValidSubject = BehaviorSubject<Bool>(value: false)
    let termsSubject = PublishSubject<Void>()
    let pinCodeSubject = BehaviorSubject<String?>(value: nil)
    let errorSubject = PublishSubject<String>()
    let shakeSubject = PublishSubject<Void>()
    let keyPressSubject = PublishSubject<String>()
    let loaderSubject = PublishSubject<Bool>()
    let hideTermsViewSubject = BehaviorSubject(value: false)
    let localizedTextSubject: BehaviorSubject<ConfirmCardPinViewStrings>

    // MARK: Internal Properties and ViewModels
    private var cardsRepository: CardsRepositoryType
    private var pinCodeWillConfirm: String
    private var cardSerialNumber: String

    let disposeBag = DisposeBag()
    var pinRange = 4...4

    // MARK: - Init

    public init(cardsRepository: CardsRepositoryType,
                pinCodeWillConfirm: String,
                cardSerialNumber: String,
                strings: ConfirmCardPinViewStrings,
                hideTermsView: Bool = false) {

        self.cardsRepository = cardsRepository
        self.pinCodeWillConfirm = pinCodeWillConfirm
        self.cardSerialNumber = cardSerialNumber

        self.localizedTextSubject = BehaviorSubject<ConfirmCardPinViewStrings>(value: strings)
        self.hideTermsViewSubject.onNext(hideTermsView)

        let keyPress = keyPressSubject.share()
        let pinCode = pinCodeSubject.share()
        keyPress.map{ _ in "" }.bind(to: errorSubject).disposed(by: disposeBag)
        keyPress.withLatestFrom(Observable.combineLatest(pinCode, keyPress)).withUnretained(self)
            .map { $0.0.mapKeyStroke(pin: $0.1.0, keyStroke: $0.1.1, pinSize: $0.0.pinRange.upperBound) }
            .bind(to: pinCodeSubject).disposed(by: disposeBag)

        pinCode.distinctUntilChanged()
            .map({ [unowned self] in ($0 ?? "").count >= self.pinRange.lowerBound })
            .bind(to: isPinValidSubject)
            .disposed(by: disposeBag)

        let setPinRequest = nextSubject.withLatestFrom(pinCodeSubject).unwrap().withUnretained(self)
            .filter({ `self`, pin in
                if pin == self.pinCodeWillConfirm {
                    return true
                } else {
                    self.errorSubject.onNext("PIN does not match")
                    return false
                }
            })
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .flatMap{ `self`, pin in
                self.cardsRepository.setPin(cardSerialNumber: self.cardSerialNumber, pin: pin)
            }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        setPinRequest.errors()
            .map({ $0.localizedDescription })
            .bind(to: errorSubject)
            .disposed(by: disposeBag)

        setPinRequest.elements().map({ $0 ?? ""})
            .bind(to: nextResultSubject)
            .disposed(by: disposeBag)
    }
}

struct ConfirmCardPinViewStrings {
    var heading: String
    var agrement: String
    var terms: String
    var next: String
}

fileprivate extension ConfirmCardPinViewModel {
    func mapKeyStroke(pin: String?, keyStroke: String, pinSize: Int) -> String {
        var pin = pin ?? ""
        if keyStroke == "\u{08}" { if !pin.isEmpty { pin.removeLast() } }
        else { if pin.count < pinSize { pin += keyStroke } }
        return pin
    }
}

