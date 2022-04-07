//
//  NewPinConfirmViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/12/2021.
//

import RxSwift

protocol NewPinConfirmViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var nextObserver: AnyObserver<Void> { get }
    var termsObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol NewPinConfirmViewModelOutputs {
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var isPinValid: Observable<Bool> { get }
    var pinCode: Observable<String?> { get }
    var error: Observable<String> { get }
    var terms: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var localizedText: Observable<NewPinConfirmViewStrings> { get }
}

protocol NewPinConfirmViewModelType {
    var inputs: NewPinConfirmViewModelInputs { get }
    var outputs: NewPinConfirmViewModelOutputs { get }
}

class NewPinConfirmViewModel: NewPinConfirmViewModelType, NewPinConfirmViewModelInputs, NewPinConfirmViewModelOutputs {

    // MARK: - Properties
    var inputs: NewPinConfirmViewModelInputs { self }
    var outputs: NewPinConfirmViewModelOutputs { self }

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
    var next: Observable<Void> { nextResultSubject.asObserver() }
    var back: Observable<Void> { backSubject.asObservable() }
    var localizedText: Observable<NewPinConfirmViewStrings> { localizedTextSubject.asObservable() }

    // MARK: - Subjects
    let nextSubject = PublishSubject<Void>()
    let nextResultSubject = PublishSubject<Void>()
    let backSubject = PublishSubject<Void>()
    let isPinValidSubject = BehaviorSubject<Bool>(value: false)
    let termsSubject = PublishSubject<Void>()
    let pinCodeSubject = BehaviorSubject<String?>(value: nil)
    let errorSubject = PublishSubject<String>()
    let shakeSubject = PublishSubject<Void>()
    let keyPressSubject = PublishSubject<String>()
    let loaderSubject = PublishSubject<Bool>()
    let localizedTextSubject: BehaviorSubject<NewPinConfirmViewStrings>

    // MARK: Internal Properties and ViewModels
    let repository: CardsRepositoryType
    let cardSerialNumber: String
    let oldPin: String
    let newPin: String
    let disposeBag = DisposeBag()
    var pinRange = 4...4

    // MARK: - Init

    public init(cardSerialNumber: String,
                oldPin: String,
                newPin: String,
                strings: NewPinConfirmViewStrings,
                repository: CardsRepositoryType) {

        self.cardSerialNumber = cardSerialNumber
        self.oldPin = oldPin
        self.newPin = newPin
        self.localizedTextSubject = BehaviorSubject<NewPinConfirmViewStrings>(value: strings)
        self.repository = repository

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

        let validatePin = nextSubject.withLatestFrom(pinCodeSubject).unwrap().share()

        let pinChange = validatePin.withUnretained(self)
            .filter{ `self`, confirm in self.validatePin(newPin: self.newPin, confirmPin: confirm).isValid }
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .map{ `self`, confirm in (self.repository, self.oldPin, self.newPin, confirm, self.cardSerialNumber) }
            .flatMap { $0.changeCardPin(oldPin: $1, newPin: $2, confirmPin: $3, cardSerialNumber: $4) }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        pinChange.elements().map{ _ in () }
            .bind(to: nextResultSubject)
            .disposed(by: disposeBag)

        validatePin.withUnretained(self)
            .map{ `self`, confirm in self.validatePin(newPin: self.newPin, confirmPin: confirm).error }.unwrap()
            .bind(to: errorSubject)
            .disposed(by: disposeBag)

        pinChange.errors().map({ $0.localizedDescription })
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
}

struct NewPinConfirmViewStrings {
    var heading: String
    var agrement: String
    var terms: String
    var next: String
}

fileprivate extension NewPinConfirmViewModel {
    func mapKeyStroke(pin: String?, keyStroke: String, pinSize: Int) -> String {
        var pin = pin ?? ""
        if keyStroke == "\u{08}" {
            if !pin.isEmpty {
                pin.removeLast()
            }
        } else {
            if pin.count < pinSize {
                pin += keyStroke
            }
        }
        return pin
    }

    func validatePin(newPin: String, confirmPin: String) -> (isValid: Bool, error: String?) {
        if newPin == confirmPin {
            return (isValid: true, error: nil)
        } else {
            return (isValid: false, error: "This doesn't match the previously entered PIN")
        }
    }
}
