//
//  FPPassCodeViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 12/12/2021.
//

import RxSwift

protocol FPPassCodeViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var nextObserver: AnyObserver<Void> { get }
    var termsObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol FPPassCodeViewModelOutputs {
    var next: Observable<String> { get }
    var back: Observable<Void> { get }
    var isPinValid: Observable<Bool> { get }
    var pinCode: Observable<String?> { get }
    var error: Observable<String> { get }
    var terms: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var localizedText: Observable<FPPassCodeViewStrings> { get }
}

protocol FPPassCodeViewModelType {
    var inputs: FPPassCodeViewModelInputs { get }
    var outputs: FPPassCodeViewModelOutputs { get }
}

class FPPassCodeViewModel: FPPassCodeViewModelType,
                           FPPassCodeViewModelInputs,
                           FPPassCodeViewModelOutputs {

    // MARK: - Properties
    var inputs: FPPassCodeViewModelInputs { self }
    var outputs: FPPassCodeViewModelOutputs { self }

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
    var localizedText: Observable<FPPassCodeViewStrings> { localizedTextSubject.asObservable() }

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
    let localizedTextSubject: BehaviorSubject<FPPassCodeViewStrings>

    // MARK: Internal Properties and ViewModels
    let repository: CardsRepositoryType
    let disposeBag = DisposeBag()
    var pinRange = 4...4

    // MARK: - Init

    public init(strings: FPPassCodeViewStrings,
                repository: CardsRepositoryType) {

        self.localizedTextSubject = BehaviorSubject<FPPassCodeViewStrings>(value: strings)
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

        let verification = nextSubject.withLatestFrom(pinCodeSubject).unwrap().withUnretained(self)
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .map{ `self`, pin in (self.repository, pin) }
            .flatMap{ $0.verifyPasscode(passcode: $1) }
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

struct FPPassCodeViewStrings {
    var heading: String
    var agrement: String
    var terms: String
    var next: String
}

fileprivate extension FPPassCodeViewModel {
    func mapKeyStroke(pin: String?, keyStroke: String, pinSize: Int) -> String {
        var pin = pin ?? ""
        if keyStroke == "\u{08}" { if !pin.isEmpty { pin.removeLast() } }
        else { if pin.count < pinSize { pin += keyStroke } }
        return pin
    }
}
