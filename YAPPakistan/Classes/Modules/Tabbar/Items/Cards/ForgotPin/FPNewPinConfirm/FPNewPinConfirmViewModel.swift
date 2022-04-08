//
//  FPNewPinConfirmViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 12/12/2021.
//

import RxSwift

protocol FPNewPinConfirmViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var nextObserver: AnyObserver<Void> { get }
    var termsObserver: AnyObserver<Void> { get }
    var otpTokenObserver: AnyObserver<String> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol FPNewPinConfirmViewModelOutputs {
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var isPinValid: Observable<Bool> { get }
    var pinCode: Observable<String?> { get }
    var verifyOTP: Observable<Void> { get }
    var error: Observable<String> { get }
    var terms: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var localizedText: Observable<FPNewPinConfirmViewStrings> { get }
}

protocol FPNewPinConfirmViewModelType {
    var inputs: FPNewPinConfirmViewModelInputs { get }
    var outputs: FPNewPinConfirmViewModelOutputs { get }
}

class FPNewPinConfirmViewModel: FPNewPinConfirmViewModelType,
                                FPNewPinConfirmViewModelInputs,
                                FPNewPinConfirmViewModelOutputs {
    // MARK: - Properties
    var inputs: FPNewPinConfirmViewModelInputs { self }
    var outputs: FPNewPinConfirmViewModelOutputs { self }

    // MARK: - Inputs - Implementation of "inputs" protocol
    var keyPressObserver: AnyObserver<String> { keyPressSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var termsObserver: AnyObserver<Void> { termsSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var otpTokenObserver: AnyObserver<String> { otpTokenSubject.asObserver() }

    // MARK: - Outputs - Implementation of "outputs" protocol
    var isPinValid: Observable<Bool> { isPinValidSubject.asObservable() }
    var pinCode: Observable<String?> { pinCodeSubject
            .map { String($0?.map{ _ in Character("\u{25CF}") } ?? []) }.asObservable()
        }
    var error: Observable<String> { errorSubject.asObservable() }
    var terms: Observable<Void> { termsSubject.asObservable() }
    var loader: Observable<Bool> { loaderSubject.asObservable() }
    var next: Observable<Void> { nextResultSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var verifyOTP: Observable<Void> { verifyOTPSubject.asObservable() }
    var localizedText: Observable<FPNewPinConfirmViewStrings> { localizedTextSubject.asObservable() }

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
    let verifyOTPSubject = PublishSubject<Void>()
    let otpTokenSubject = PublishSubject<String>()
    let localizedTextSubject: BehaviorSubject<FPNewPinConfirmViewStrings>

    // MARK: Internal Properties and ViewModels
    let pinRange = 4...4
    let cardSerialNumber: String
    let passCode: String
    let newPin: String
    let disposeBag = DisposeBag()
    let repository: CardsRepositoryType

    // MARK: - Init

    public init(cardSerialNumber: String,
                passCode: String,
                newPin: String,
                strings: FPNewPinConfirmViewStrings,
                repository: CardsRepositoryType) {

        self.cardSerialNumber = cardSerialNumber
        self.passCode = passCode
        self.newPin = newPin
        self.repository = repository
        self.localizedTextSubject = BehaviorSubject<FPNewPinConfirmViewStrings>(value: strings)

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
        let validationError = validatePin.withUnretained(self)
            .map{ `self`, confirm in self.validatePin(newPin: self.newPin, confirmPin: confirm).error }.unwrap()

        // Generate OTP Verification Code
        // Fetch OTP Verification Token
        let pinChange = validatePin.withUnretained(self)
            .filter{ `self`, confirm in
                self.validatePin(newPin: self.newPin, confirmPin: confirm).isValid }
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .flatMap{ `self`, _ in self.repository.generateOTP(action: .forgotCardPin) }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        pinChange.elements().map{ _ in () }
            .bind(to: verifyOTPSubject)
            .disposed(by: disposeBag)

        let pinChangeRequest = otpTokenSubject.withUnretained(self)
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .map{ `self`, token in (self.repository, self.newPin, token, self.cardSerialNumber) }
            .flatMap{ $0.forgotCardPin(newPin: $1, token: $2, cardSerialNumber: $3) }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        pinChangeRequest.elements().map{ _ in () }
            .bind(to: nextResultSubject)
            .disposed(by: disposeBag)

        validationError
            .merge(with: pinChange.errors().map{ $0.localizedDescription })
            .merge(with: pinChangeRequest.errors().map{ $0.localizedDescription })
            .bind(to: errorSubject)
            .disposed(by: disposeBag)

    }
}

struct FPNewPinConfirmViewStrings {
    var heading: String
    var agrement: String
    var terms: String
    var next: String
}

fileprivate extension FPNewPinConfirmViewModel {
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
