//
//  PasscodeViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 29/09/2021.
//

import RxSwift
// public typealias OTPVerificationResult = (token: String?, phoneNumber: String?)
struct PasscodeViewStrings {
    var heading: String
    var agrement: String
    var terms: String
    var action:String
}

protocol PasscodeViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var actionObserver: AnyObserver<Void> { get }
    var termsAndConditionsActionObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol PasscodeViewModelOutputs {
    var result: Observable<String> { get }
    var pinValid: Observable<Bool> { get }
    var pinText: Observable<String?> { get }
    var error: Observable<String> { get }
    var shake: Observable<Void> { get }
    var back: Observable<Void> { get }
    var openTermsAndCondtions: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var localizedText: Observable<PasscodeViewStrings> { get }
}

protocol PasscodeViewModelType {
    var inputs: PasscodeViewModelInputs { get }
    var outputs: PasscodeViewModelOutputs { get }
}

class PasscodeViewModel: PasscodeViewModelType, PasscodeViewModelInputs, PasscodeViewModelOutputs {

    // MARK: - Properties
    public var inputs: PasscodeViewModelInputs { self }
    public var outputs: PasscodeViewModelOutputs { self }

    // MARK: - Inputs - Implementation of "inputs" protocol
    public var keyPressObserver: AnyObserver<String> { keyPressSubject.asObserver() }
    public var actionObserver: AnyObserver<Void> { actionSubject.asObserver() }
    public var termsAndConditionsActionObserver: AnyObserver<Void> { termsAndConditionsActionSubject.asObserver() }
    public var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: - Outputs - Implementation of "outputs" protocol
    public var result: Observable<String> { resultSubject.asObservable() }
    public var pinValid: Observable<Bool> { pinValidSubject.asObservable() }
    public var pinText: Observable<String?> { pinTextSubject.asObservable() }
    public var error: Observable<String> { errorSubject.asObservable() }
    public var shake: Observable<Void> { shakeSubject.asObservable() }
    public var back: Observable<Void> { backSubject.asObservable() }
    public var openTermsAndCondtions: Observable<Void> { termsAndConditionsActionSubject.asObservable() }
    public var loader: Observable<Bool> { loaderSubject.asObservable() }
    public var localizedText: Observable<PasscodeViewStrings> { localizedTextSubject.asObservable() }

    // MARK: - Subjects
    public let resultSubject = PublishSubject<String>()
    internal let pinValidSubject = BehaviorSubject<Bool>(value: false)
    internal let termsAndConditionsActionSubject = PublishSubject<Void>()
    public let pinTextSubject = BehaviorSubject<String?>(value: nil)
    public let errorSubject = PublishSubject<String>()
    public let shakeSubject = PublishSubject<Void>()
    public let actionSubject = PublishSubject<Void>()
    internal let keyPressSubject = PublishSubject<String>()
    internal let backSubject = PublishSubject<Void>()
    internal let loaderSubject = PublishSubject<Bool>()
    internal let localizedTextSubject: BehaviorSubject<PasscodeViewStrings>

    // MARK: Internal Properties and ViewModels
    public let disposeBag = DisposeBag()
    private let pinRange: ClosedRange<Int>

    // MARK: - Init
    public init(pinRange: ClosedRange<Int>, localizeableKeys: PasscodeViewStrings) {

        self.pinRange = pinRange
        self.localizedTextSubject = BehaviorSubject<PasscodeViewStrings>(value: PasscodeViewStrings(
            heading: localizeableKeys.heading,
            agrement: localizeableKeys.agrement,
            terms: localizeableKeys.terms,
            action: localizeableKeys.action
        ))

        keyPressSubject.withLatestFrom(Observable.combineLatest(keyPressSubject, pinTextSubject))
            .do(onNext: { [unowned self] _ in errorSubject.onNext("") })
            .map { keyStroke, pin -> String in
                var pin = pin ?? ""
                if keyStroke == "\u{08}" {
                    if !pin.isEmpty { pin.removeLast() }
                } else {
                    if pin.count < pinRange.upperBound { pin += keyStroke }
                }
                return pin
            }.bind(to: pinTextSubject).disposed(by: disposeBag)

        pinTextSubject.distinctUntilChanged()
            .map({ [unowned self] in ($0 ?? "").count >= self.pinRange.lowerBound })
            .bind(to: pinValidSubject)
            .disposed(by: disposeBag)

        backSubject.subscribe(onCompleted: { [unowned self] in
            self.resultSubject.onCompleted()
        }).disposed(by: disposeBag)
    }
}
