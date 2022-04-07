//
//  NewPinViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/12/2021.
//

import RxSwift

protocol NewPinViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var nextObserver: AnyObserver<Void> { get }
    var termsObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol NewPinViewModelOutputs {
    var next: Observable<String> { get }
    var back: Observable<Void> { get }
    var isPinValid: Observable<Bool> { get }
    var pinCode: Observable<String?> { get }
    var error: Observable<String> { get }
    var terms: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var localizedText: Observable<NewPinViewStrings> { get }
}

protocol NewPinViewModelType {
    var inputs: NewPinViewModelInputs { get }
    var outputs: NewPinViewModelOutputs { get }
}

class NewPinViewModel: NewPinViewModelType, NewPinViewModelInputs, NewPinViewModelOutputs {

    // MARK: - Properties
    var inputs: NewPinViewModelInputs { self }
    var outputs: NewPinViewModelOutputs { self }

    // MARK: - Inputs - Implementation of "inputs" protocol
    var keyPressObserver: AnyObserver<String> { keyPressSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var termsObserver: AnyObserver<Void> { termsSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: - Outputs - Implementation of "outputs" protocol
    var isPinValid: Observable<Bool> { isPinValidSubject.asObservable() }
    var pinCode: Observable<String?> { pinCodeSubject
            .map { String($0?.map{ _ in Character("\u{25CF}") } ?? []) }.asObservable()
        }
    var error: Observable<String> { errorSubject.asObservable() }
    var terms: Observable<Void> { termsSubject.asObservable() }
    var loader: Observable<Bool> { loaderSubject.asObservable() }
    var next: Observable<String> { nextResultSubject.asObserver() }
    var back: Observable<Void> { backSubject.asObservable() }
    var localizedText: Observable<NewPinViewStrings> { localizedTextSubject.asObservable() }

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
    let localizedTextSubject: BehaviorSubject<NewPinViewStrings>

    // MARK: Internal Properties and ViewModels
    let disposeBag = DisposeBag()
    var pinRange = 4...4

    // MARK: - Init

    public init(strings: NewPinViewStrings) {

        self.localizedTextSubject = BehaviorSubject<NewPinViewStrings>(value: strings)

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

        nextSubject.withLatestFrom(pinCodeSubject).unwrap()
            .subscribe(onNext:{ [unowned self] pin in
                do {
                    try ValidationService.shared.validatePasscode(pin)
                    self.nextResultSubject.onNext(pin)
                } catch {
                    switch error as! ValidationError {
                    case .passcodeSequence:
                        self.errorSubject.onNext("screen_set_card_pin_display_text_error_sequence".localized)
                    case .passcodeSameDigits:
                        self.errorSubject.onNext("screen_set_card_pin_display_text_error_same_digits".localized)
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

struct NewPinViewStrings {
    var heading: String
    var agrement: String
    var terms: String
    var next: String
}

fileprivate extension NewPinViewModel {
    func mapKeyStroke(pin: String?, keyStroke: String, pinSize: Int) -> String {
        var pin = pin ?? ""
        if keyStroke == "\u{08}" { if !pin.isEmpty { pin.removeLast() } }
        else { if pin.count < pinSize { pin += keyStroke } }
        return pin
    }
}
