//
//  VerifyCurrentPinViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/12/2021.
//

import RxSwift

protocol VerifyCurrentPinViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var nextObserver: AnyObserver<Void> { get }
    var termsObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var forgotObserver: AnyObserver<Void> { get }
}

protocol VerifyCurrentPinViewModelOutputs {
    var next: Observable<String> { get }
    var back: Observable<Void> { get }
    var forgot: Observable<Void> { get }
    var isPinValid: Observable<Bool> { get }
    var pinCode: Observable<String?> { get }
    var error: Observable<String> { get }
    var terms: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var localizedText: Observable<VerifyCurrentPinViewStrings> { get }
}

protocol VerifyCurrentPinViewModelType {
    var inputs: VerifyCurrentPinViewModelInputs { get }
    var outputs: VerifyCurrentPinViewModelOutputs { get }
}

class VerifyCurrentPinViewModel: VerifyCurrentPinViewModelType,
                                 VerifyCurrentPinViewModelInputs,
                                 VerifyCurrentPinViewModelOutputs {

    // MARK: - Properties
    var inputs: VerifyCurrentPinViewModelInputs { self }
    var outputs: VerifyCurrentPinViewModelOutputs { self }

    // MARK: - Inputs - Implementation of "inputs" protocol
    var keyPressObserver: AnyObserver<String> { keyPressSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var termsObserver: AnyObserver<Void> { termsSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var forgotObserver: AnyObserver<Void> { forgotSubject.asObserver() }

    // MARK: - Outputs - Implementation of "outputs" protocol
    var isPinValid: Observable<Bool> { isPinValidSubject.asObservable() }
    var pinCode: Observable<String?> { pinCodeSubject
        .map{ String($0?.map{ _ in Character("\u{25CF}") } ?? []) }.asObservable()
    }
    var error: Observable<String> { errorSubject.asObservable() }
    var terms: Observable<Void> { termsSubject.asObservable() }
    var loader: Observable<Bool> { loaderSubject.asObservable() }
    var next: Observable<String> { nextResultSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var localizedText: Observable<VerifyCurrentPinViewStrings> { localizedTextSubject.asObservable() }
    var forgot: Observable<Void> { forgotSubject.asObservable() }

    // MARK: - Subjects
    let nextSubject = PublishSubject<Void>()
    let nextResultSubject = PublishSubject<String>()
    let backSubject = PublishSubject<Void>()
    let forgotSubject = PublishSubject<Void>()
    let isPinValidSubject = BehaviorSubject<Bool>(value: false)
    let termsSubject = PublishSubject<Void>()
    let pinCodeSubject = BehaviorSubject<String?>(value: nil)
    let errorSubject = PublishSubject<String>()
    let shakeSubject = PublishSubject<Void>()
    let keyPressSubject = PublishSubject<String>()
    let loaderSubject = PublishSubject<Bool>()
    let localizedTextSubject: BehaviorSubject<VerifyCurrentPinViewStrings>

    // MARK: Internal Properties and ViewModels
    let repository: CardsRepositoryType
    let cardSerialNumber: String
    let disposeBag = DisposeBag()
    var pinRange = 4...4

    // MARK: - Init

    public init(cardSerialNumber: String,
                strings: VerifyCurrentPinViewStrings,
                repository: CardsRepositoryType) {

        self.cardSerialNumber = cardSerialNumber
        self.localizedTextSubject = BehaviorSubject<VerifyCurrentPinViewStrings>(value: strings)
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

        let verification = nextSubject
            .withLatestFrom(pinCodeSubject).unwrap().withUnretained(self)
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .map{ `self`, pin in (self.repository, pin, self.cardSerialNumber) }
            .flatMap({ repo, pin, serialNumber in repo.verifyCardPin(cardSerialNumber: serialNumber, pin: pin) })
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        verification.elements().withLatestFrom(pinCodeSubject).unwrap()
            .bind(to: nextResultSubject)
            .disposed(by: disposeBag)

        verification.errors().map({ $0.localizedDescription })
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
}

struct VerifyCurrentPinViewStrings {
    var heading: String
    var agrement: String
    var terms: String
    var next: String
}

fileprivate extension VerifyCurrentPinViewModel {
    func mapKeyStroke(pin: String?, keyStroke: String, pinSize: Int) -> String {
        let pin = pin ?? ""
        let backSpaceResult = String(pin.dropLast())
        let keyStrokeResult = pin.count < pinSize ? pin + keyStroke : pin
        return keyStroke == "\u{08}" ? backSpaceResult : keyStrokeResult
    }
}
