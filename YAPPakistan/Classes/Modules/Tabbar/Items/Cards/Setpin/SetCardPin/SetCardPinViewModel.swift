//
//  SetCardPinViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/11/2021.
//

import RxSwift

protocol SetCardPinViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var nextObserver: AnyObserver<Void> { get }
    var termsObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol SetCardPinViewModelOutputs {
    typealias SetPinResult = (pinCode: String, cardSerial:String)
    var next: Observable<SetPinResult> { get }
    var back: Observable<Void> { get }
    var isPinValid: Observable<Bool> { get }
    var pinCode: Observable<String?> { get }
    var error: Observable<String> { get }
    var terms: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var hideTermsView: Observable<Bool> { get }
    var localizedText: Observable<SetCardPinViewStrings> { get }
}

protocol SetCardPinViewModelType {
    var inputs: SetCardPinViewModelInputs { get }
    var outputs: SetCardPinViewModelOutputs { get }
}

class SetCardPinViewModel: SetCardPinViewModelType, SetCardPinViewModelInputs, SetCardPinViewModelOutputs {

    // MARK: - Properties
    var inputs: SetCardPinViewModelInputs { self }
    var outputs: SetCardPinViewModelOutputs { self }

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
    var next: Observable<SetPinResult> { nextResultSubject.asObserver() }
    var back: Observable<Void> { backSubject.asObservable() }
    var hideTermsView: Observable<Bool> { hideTermsViewSubject.asObservable() }
    var localizedText: Observable<SetCardPinViewStrings> { localizedTextSubject.asObservable() }

    // MARK: - Subjects
    let nextSubject = PublishSubject<Void>()
    let nextResultSubject = PublishSubject<SetPinResult>()
    let backSubject = PublishSubject<Void>()
    let isPinValidSubject = BehaviorSubject<Bool>(value: false)
    let termsSubject = PublishSubject<Void>()
    let pinCodeSubject = BehaviorSubject<String?>(value: nil)
    let errorSubject = PublishSubject<String>()
    let shakeSubject = PublishSubject<Void>()
    let keyPressSubject = PublishSubject<String>()
    let loaderSubject = PublishSubject<Bool>()
    let hideTermsViewSubject = BehaviorSubject(value: true)
    let localizedTextSubject: BehaviorSubject<SetCardPinViewStrings>

    // MARK: Internal Properties and ViewModels
    let cardSerialNumber: String
    let disposeBag = DisposeBag()
    var pinRange = 4...4

    // MARK: - Init

    public init(cardSerialNumber: String,
                strings: SetCardPinViewStrings,
                hideTermsView: Bool = true) {

        self.cardSerialNumber = cardSerialNumber
        self.localizedTextSubject = BehaviorSubject<SetCardPinViewStrings>(value: strings)
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

        nextSubject.withLatestFrom(pinCodeSubject).unwrap().withUnretained(self)
            .map{ `self`, pin in (pin, self.cardSerialNumber) }
            .bind(to: nextResultSubject)
            .disposed(by: disposeBag)
    }
}

struct SetCardPinViewStrings {
    var heading: String
    var agrement: String
    var terms: String
    var next: String
}

fileprivate extension SetCardPinViewModel {
    func mapKeyStroke(pin: String?, keyStroke: String, pinSize: Int) -> String {
        var pin = pin ?? ""
        if keyStroke == "\u{08}" { if !pin.isEmpty { pin.removeLast() } }
        else { if pin.count < pinSize { pin += keyStroke } }
        return pin
    }
}
