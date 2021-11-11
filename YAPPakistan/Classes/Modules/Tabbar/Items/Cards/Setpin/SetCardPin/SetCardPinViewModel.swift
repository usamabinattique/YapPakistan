//
//  SetCardPinViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/11/2021.
//

import RxSwift

protocol SetCardPinViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var actionObserver: AnyObserver<Void> { get }
    var termsObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol SetCardPinViewModelOutputs {
    var isPinValid: Observable<Bool> { get }
    var pinCode: Observable<String?> { get }
    var error: Observable<String> { get }
    var terms: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var success: Observable<Void> { get }
    var back: Observable<Void> { get }
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
    var actionObserver: AnyObserver<Void> { actionSubject.asObserver() }
    var termsObserver: AnyObserver<Void> { termsSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: - Outputs - Implementation of "outputs" protocol
    var isPinValid: Observable<Bool> { isPinValidSubject.asObservable() }
    var pinCode: Observable<String?> { pinCodeSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var terms: Observable<Void> { termsSubject.asObservable() }
    var loader: Observable<Bool> { loaderSubject.asObservable() }
    var success: Observable<Void> { successSubject.asObserver() }
    var back: Observable<Void> { backSubject.asObservable() }
    var localizedText: Observable<SetCardPinViewStrings> { localizedTextSubject.asObservable() }

    // MARK: - Subjects
    let successSubject = PublishSubject<Void>()
    let isPinValidSubject = BehaviorSubject<Bool>(value: false)
    let termsSubject = PublishSubject<Void>()
    let pinCodeSubject = BehaviorSubject<String?>(value: nil)
    let errorSubject = PublishSubject<String>()
    let shakeSubject = PublishSubject<Void>()
    let actionSubject = PublishSubject<Void>()
    let keyPressSubject = PublishSubject<String>()
    let backSubject = PublishSubject<Void>()
    let loaderSubject = PublishSubject<Bool>()
    let localizedTextSubject: BehaviorSubject<SetCardPinViewStrings>

    // MARK: Internal Properties and ViewModels
    public let disposeBag = DisposeBag()
    var pinRange = 4...4

    // MARK: - Init

    public init(localizeableKeys: SetCardPinViewStrings) {

        self.localizedTextSubject = BehaviorSubject<SetCardPinViewStrings>(value: localizeableKeys)

        let keyPress = keyPressSubject.share()
        let pinCode = pinCodeSubject.share()
        keyPress.map {_ in "" }.bind(to: errorSubject).disposed(by: disposeBag)
        Observable.combineLatest(pinCode, keyPress).withUnretained(self)
            .map { $0.0.mapKeyStroke(pin: $0.1.0, keyStroke: $0.1.1, pinSize: $0.0.pinRange.upperBound) }
            .bind(to: pinCodeSubject).disposed(by: disposeBag)

        pinCode.distinctUntilChanged()
            .map({ [unowned self] in ($0 ?? "").count >= self.pinRange.lowerBound })
            .bind(to: isPinValidSubject)
            .disposed(by: disposeBag)
    }
}

struct SetCardPinViewStrings {
    var heading: String
    var agrement: String
    var terms: String
    var action:String
}

fileprivate extension SetCardPinViewModel {
    func mapKeyStroke(pin: String?, keyStroke: String, pinSize: Int) -> String {
        var pin = pin ?? ""
        if keyStroke == "\u{08}" { if !pin.isEmpty { pin.removeLast() } }
        else { if pin.count < pinSize { pin += keyStroke } }
        return pin
    }
}
