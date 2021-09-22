//
//  VerifyPasscodeViewModel.swift
//  Alamofire
//
//  Created by Sarmad on 20/09/2021.
//

import RxSwift

public protocol VerifyPasscodeViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var actionObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var forgotPasscodeObserver: AnyObserver<Void> { get }
}

public protocol VerifyPasscodeViewModelOutputs {
    typealias LocalizedText = (heading: String, signIn: String, forgot:String)
    var result: Observable<String> { get }
    var pinValid: Observable<Bool> { get }
    var pinText: Observable<String?> { get }
    var error: Observable<String> { get }
    var back: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var localizedText: Observable<LocalizedText> { get }
}

public protocol VerifyPasscodeViewModelType {
    var inputs: VerifyPasscodeViewModelInputs { get }
    var outputs: VerifyPasscodeViewModelOutputs { get }
}

open class VerifyPasscodeViewModel: VerifyPasscodeViewModelType, VerifyPasscodeViewModelInputs, VerifyPasscodeViewModelOutputs {
    
    
    // MARK: - Properties
    public var inputs: VerifyPasscodeViewModelInputs { return self }
    public var outputs: VerifyPasscodeViewModelOutputs { return self }
    
    // MARK: - Inputs - Implementation of "inputs" protocol
    public var keyPressObserver: AnyObserver<String> { return keyPressSubject.asObserver() }
    public var actionObserver: AnyObserver<Void> { return actionSubject.asObserver() }
    public var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    public var forgotPasscodeObserver: AnyObserver<Void> { return forgotPasscodeSubject.asObserver() }
    
    // MARK: - Outputs - Implementation of "outputs" protocol
    public var pinText: Observable<String?> { return pinTextSubject.map({ String($0?.map{ _ in Character("\u{25CF}") } ?? []) }).asObservable() }
    public var error: Observable<String> { return errorSubject.asObservable() }
    public var result: Observable<String> { return resultSubject.asObservable() }
    public var pinValid: Observable<Bool> { return pinValidSubject.asObservable() }
    public var back: Observable<Void> { return backSubject.asObservable() }
    public var forgotPasscode: Observable<Void> { return forgotPasscodeSubject.asObservable() }
    public var loader: Observable<Bool> { return loaderSubject.asObservable() }
    public var localizedText: Observable<LocalizedText> { return self.localizedTextSubject.asObservable() }
    
    // MARK: - Subjects
    fileprivate let resultSubject = PublishSubject<String>()
    fileprivate let pinValidSubject = BehaviorSubject<Bool>(value: false)
    fileprivate let pinTextSubject = BehaviorSubject<String?>(value: nil)
    fileprivate let errorSubject = PublishSubject<String>()
    fileprivate let actionSubject = PublishSubject<Void>()
    fileprivate let keyPressSubject = PublishSubject<String>()
    fileprivate let backSubject = PublishSubject<Void>()
    fileprivate let forgotPasscodeSubject = PublishSubject<Void>()
    fileprivate let loaderSubject = PublishSubject<Bool>()
    fileprivate let localizedTextSubject:BehaviorSubject<LocalizedText>
    
    // MARK: Internal Properties and ViewModels
    private let repository: LoginRepository
    private let pinRange: ClosedRange<Int>
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(repository: LoginRepository, pinRange: ClosedRange<Int> = 4...6) {
        
        self.repository = repository
        self.pinRange = pinRange
        
        self.localizedTextSubject = BehaviorSubject(value:(
            "screen_enter_passcode_display_text_title".localized,
            "screen_create_passcode_button_signin".localized,
            "screen_create_passcode_button_forgot_passcode".localized
        ))
        
        let pinText = pinTextSubject.distinctUntilChanged().share()
        
        keyPressSubject.withLatestFrom(Observable.combineLatest(keyPressSubject, pinText))
            .debug("PINOB", trimOutput: false)
            .map { (keyStroke, pin) -> String in
                var pin = pin ?? ""
                if keyStroke == "\u{08}" {
                    if !pin.isEmpty { pin.removeLast() }
                } else {
                    if pin.count < pinRange.upperBound { pin += keyStroke }
                }
                return pin
            }.bind(to: pinTextSubject).disposed(by: disposeBag)
        
        pinTextSubject.map({ [unowned self] in ($0 ?? "").count >= self.pinRange.lowerBound })
            .bind(to: pinValidSubject)
            .disposed(by: disposeBag)

        bindUserAuthentication(repository: repository)
    }
}


fileprivate extension VerifyPasscodeViewModel {
    func bindUserAuthentication(repository: LoginRepository) {
        
        let loginRequest = actionSubject.withLatestFrom(pinText)
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(true) })
            .flatMap { pinCode in
                self.repository.authenticate(username: "00923331599998", password: pinCode ?? "", deviceId: UIDevice.deviceID)
            }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()
        
        loginRequest.elements().unwrap().map { $0["id_token"] ?? "" }.unwrap()
            .filter{ $0.isEmpty }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)
        
        let apiError = loginRequest.errors().withUnretained(self).share()
        let invalidCredentials = apiError.map({ $0.0.inValidCredentials(error: $0.1) })  // invalidCredentials
            .filter({ $0.0 == true })
            .map({ $0.1 })
        let errorOther = apiError.filter({ !$0.0.isErrorAuthFailure(error: $0.1) && !$0.0.isErrorAccountLocked(error: $0.1) })
            .map({ $0.1.localizedDescription }) // errorSubject
        let optBlocked = apiError.filter{ $0.0.isOTPBlocked(error: $0.1) }
            .map{ ($0.1 as? AuthenticationError)?.errorDescription }.unwrap() // OTP Blocked: Alert message
        
        let accountLocked = apiError.filter { $0.0.isErrorAccountLocked(error: $0.1) }
            .map({ $0.1.localizedDescription })
        let accountFreezed = apiError.filter { $0.0.isErrorAccountFreeze(error: $0.1) }
            .map { $0.0.getFreezeErrorDescription(error: $0.1) }.unwrap()
        
        Observable.merge(invalidCredentials, errorOther, optBlocked, accountLocked, accountFreezed)
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
}

//MARK: Helpers
fileprivate extension UIDevice {
    static var deviceID:String { UIDevice.current.identifierForVendor?.uuidString ?? "" }
}

fileprivate extension VerifyPasscodeViewModel {
    
    func inValidCredentials(error: Error) -> (Bool, String) {
        if case let AuthenticationError.serverError(code, message) = error {
            return (code == 301, message)
        }
        return (false, "")
    }
    
    func isErrorAuthFailure(error: Error) -> Bool {
        if case let AuthenticationError.serverError(code, _) = error {
            return code == 303
        }
        return false
    }
    
    func getIncorrectAttemptsHoldTime(error: Error ) -> TimeInterval {
        if case let AuthenticationError.serverError(code, timeInterval) = error,
            code == 303 {
            return TimeInterval(timeInterval) ?? 120
        }
        return 120
    }
    
    func isErrorAccountLocked(error: Error) -> Bool {
        if case let AuthenticationError.serverError(code, _) = error {
            return code == 302
        }
        return false
    }
    
    func isErrorAccountFreeze(error: Error) -> Bool {
        if case let AuthenticationError.serverError(code, _) = error {
            return code == 1260
        }
        return false
    }
    
    func isOTPBlocked(error: Error) -> Bool {
        if case let AuthenticationError.serverError(code, _) = error {
            return code == 1062 || code == 1066 || code == 1095
        }
        return false
    }
    
    func getFreezeErrorDescription(error: Error) -> String? {
        if case let AuthenticationError.serverError(_, message) = error {
            return message
        }
        return nil
    }
    
    func timeString(prefix: String, timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval/60.0)
        let seconds = Int(timeInterval) % 60
        
        return String.init(format: "%@ %02d:%02d", prefix, minutes, seconds)
    }

}
