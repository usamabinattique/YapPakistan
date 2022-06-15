//
//  CreatePasscodeViewModel.swift
//  YAP
//
//  Created by Zain on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import RxSwift
import YAPCore

public typealias OTPVerificationResult = (token: String?, phoneNumber: String?)

public protocol PINViewModelInputs {
    // This protocol must contain only those properties required by ViewController or Coordinator.
    var pinObserver: AnyObserver<String?> { get }
    var pinChangeObserver: AnyObserver<String> { get }
    var actionObserver: AnyObserver<Void> { get }
    var termsAndConditionsActionObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var forgotPasscodeObserver: AnyObserver<Void> { get }
    var requestForgotPINObserver: AnyObserver<OTPVerificationResult> { get }
}

public protocol PINViewModelOutputs {
    // This protocol must contain only those properties required by ViewController or Coordinator.
    var passcodeSuccess: Observable<String> { get }
    var result: Observable<String> { get }
    var pinValid: Observable<Bool> { get }
    var headingText: Observable<String?> { get }
    var termsAndConditionsText: Observable<NSAttributedString?> { get }
    var actionTitle: Observable<String?> { get }
    var pinText: Observable<NSAttributedString?> { get }
    var error: Observable<String> { get }
    var shake: Observable<Void> { get }
    var back: Observable<Void> { get }
    var enableBack: Observable<(Bool, BackButtonType)> { get }
    var username: Observable<String> { get }
    var forgotPasscode: Observable<Void> { get }
    var backImage: Observable<BackButtonType> { get }
    var forgotPasscodeEnable: Observable<Bool?> { get }
    var requestForgotPIN: Observable<OTPVerificationResult> { get }
    var verifyForgotPIN: Observable<Void> { get }
    var openTermsAndCondtions: Observable<Void> { get }
    var hideNavigationBar: Observable<Bool>{ get }
}

public protocol PINViewModelType {
    var inputs: PINViewModelInputs { get }
    var outputs: PINViewModelOutputs { get }
}

open class PINViewModel: PINViewModelType, PINViewModelInputs, PINViewModelOutputs {

    // MARK: - Properties
    public var inputs: PINViewModelInputs { return self }
    public var outputs: PINViewModelOutputs { return self }

    // MARK: - Subjects
     /*
     Define only those Subject required to satisfy inputs and outputs.
     All subjects should be internal unless needed otherwise
     */
    public let resultSubject = PublishSubject<String>()
    internal let passcodeSuccessSubject = PublishSubject<String>()
    internal let pinValidSubject = BehaviorSubject<Bool>(value: false)
    public let headingTextSubject = BehaviorSubject<String?>(value: nil)
    public let termsAndConditionsSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    internal let termsAndConditionsActionSubject = PublishSubject<Void>()
    public let actionTitleSubject = BehaviorSubject<String?>(value: nil)
    public let pinTextSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    public let errorSubject = PublishSubject<String>()
    public let shakeSubject = PublishSubject<Void>()
    public let actionSubject = PublishSubject<Void>()
    public let pinSubject = BehaviorSubject<String?>(value: nil)
    internal let pinChangeSubject = PublishSubject<String>()
    internal let backSubject = PublishSubject<Void>()
    public let enableBackSubject = BehaviorSubject<(Bool, BackButtonType)>(value: (true, .backCircled))
    internal let usernameSubject = BehaviorSubject<String>(value: "")
    internal let forgotPasscodeSubject = PublishSubject<Void>()
    public let backImageSubject = BehaviorSubject<BackButtonType>(value: .backCircled)
    internal let forgotPasscodeEnableSubject = BehaviorSubject<Bool?>(value: nil)
    internal let requestForgotPINSubject = PublishSubject<OTPVerificationResult>()
    internal let verifyForgotPINSubject = PublishSubject<Void>()
    internal let hideNavigationBarSubject = BehaviorSubject<Bool>(value: true)

    // MARK: - Inputs - Implementation of "inputs" protocol
    public var pinObserver: AnyObserver<String?> { return pinSubject.asObserver() }
    public var pinChangeObserver: AnyObserver<String> { return pinChangeSubject.asObserver() }
    public var actionObserver: AnyObserver<Void> { return actionSubject.asObserver() }
    public var termsAndConditionsActionObserver: AnyObserver<Void> { return termsAndConditionsActionSubject.asObserver() }
    public var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    public var forgotPasscodeObserver: AnyObserver<Void> { return forgotPasscodeSubject.asObserver() }
    public var requestForgotPINObserver: AnyObserver<OTPVerificationResult> { return requestForgotPINSubject.asObserver() }

    // MARK: - Outputs - Implementation of "outputs" protocol
    public var passcodeSuccess: Observable<String> { return passcodeSuccessSubject.asObservable() }
    public var result: Observable<String> { return resultSubject.asObservable() }
    public var pinValid: Observable<Bool> { return pinValidSubject.asObservable() }
    public var headingText: Observable<String?> { return headingTextSubject.asObservable() }
    public var termsAndConditionsText: Observable<NSAttributedString?> { return termsAndConditionsSubject.asObservable() }
    public var actionTitle: Observable<String?> { return actionTitleSubject.asObservable() }
    public var pinText: Observable<NSAttributedString?> { return pinTextSubject.asObservable() }
    public var error: Observable<String> { return errorSubject.asObservable() }
    public var shake: Observable<Void> { return shakeSubject.asObservable() }
    public var back: Observable<Void> { return backSubject.asObservable() }
    public var enableBack: Observable<(Bool, BackButtonType)> { return enableBackSubject.asObservable() }
    public var username: Observable<String> { return usernameSubject.asObservable() }
    public var forgotPasscode: Observable<Void> { return forgotPasscodeSubject.asObservable() }
    public var backImage: Observable<BackButtonType> { return backImageSubject.asObservable() }
    public var forgotPasscodeEnable: Observable<Bool?> { return forgotPasscodeEnableSubject.asObservable() }
    public var requestForgotPIN: Observable<OTPVerificationResult> { return requestForgotPINSubject.asObservable() }
    public var verifyForgotPIN: Observable<Void> { return verifyForgotPINSubject.asObservable() }
    public var openTermsAndCondtions: Observable<Void> { termsAndConditionsActionSubject.asObservable() }
    public var hideNavigationBar: Observable<Bool>{ return hideNavigationBarSubject.asObservable() }

    // MARK: Internal Properties and ViewModels
    public let disposeBag = DisposeBag()
    private let pinRange: ClosedRange<Int>

    // MARK: - Init
    public init(pinRange: ClosedRange<Int>, analyticsTracker: AnalyticsTracker) {
        print("range is \(pinRange)")
        self.pinRange = pinRange

        pinChangeSubject.withLatestFrom(Observable.combineLatest(pinChangeSubject, pinSubject))
            .map{ keyStroke, pin -> String in
                var pin = pin ?? ""
                if keyStroke == "\u{08}" {
                    if !pin.isEmpty {
                        pin.removeLast()
                    }
                } else {
                    if pin.count < pinRange.upperBound {
                        pin += keyStroke
                    }
                }
                return pin
            }.bind(to: pinSubject)
            .disposed(by: disposeBag)

        pinSubject.map { [unowned self] pin -> Bool in
            guard let pin = pin else { return false }
            print("pin is \(pin)")
            return self.pinRange.contains(pin.count)
        }
            .bind(to: pinValidSubject)
            .disposed(by: disposeBag)

        pinSubject
            .map {
                let attributed = NSMutableAttributedString(string: $0 ?? "")
                attributed.addAttributes([NSAttributedString.Key.kern: 7], range: NSRange(location: 0, length: attributed.length))
                return attributed
            }
            .bind(to: pinTextSubject)
            .disposed(by: disposeBag)

        backSubject.subscribe(onCompleted: { [unowned self] in
            self.resultSubject.onCompleted()
        }).disposed(by: disposeBag)
    }

   public func createTermsAndConditions(text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        let termsAndConditions = text.components(separatedBy: "\n").last ?? ""
    attributedText.addAttribute(.foregroundColor, value: UIColor.blue/*appColor(ofType: .primary)*/, range: NSRange(location: text.count - termsAndConditions.count, length: termsAndConditions.count))
        attributedText.addAttribute(.foregroundColor, value: UIColor.darkGray /*appColor(ofType: .greyDark)*/, range: NSRange(location: 0, length: text.count - termsAndConditions.count))
        return attributedText
    }
}
