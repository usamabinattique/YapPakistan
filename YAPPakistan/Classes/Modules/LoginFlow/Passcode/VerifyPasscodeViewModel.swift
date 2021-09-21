//
//  VerifyPasscodeViewModel.swift
//  Alamofire
//
//  Created by Sarmad on 20/09/2021.
//

import RxSwift
import YAPCore
//public typealias OTPVerificationResult = (token: String?, phoneNumber: String?)

public protocol VerifyPasscodeViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var actionObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var forgotPasscodeObserver: AnyObserver<Void> { get }
    
    //var pinObserver: AnyObserver<String?> { get }
    //var requestForgotPINObserver: AnyObserver<OTPVerificationResult> { get }
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
    
    
    //var passcodeSuccess: Observable<String> { get }
    //var headingText: Observable<String?> { get }
    //var termsAndConditionsText: Observable<NSAttributedString?> { get }
    //var actionTitle: Observable<String?> { get }
    //var shake: Observable<Void> { get }
    //var enableBack: Observable<(Bool, BackButtonType)> { get }
    //var username: Observable<String> { get }
    //var forgotPasscode: Observable<Void> { get }
    //var backImage: Observable<BackButtonType> { get }
    //var forgotPasscodeEnable: Observable<Bool?> { get }
    //var requestForgotPIN: Observable<OTPVerificationResult> { get }
    //var verifyForgotPIN: Observable<Void> { get }
    //var openTermsAndCondtions: Observable<Void> { get }
    //var hideNavigationBar: Observable<Bool>{ get }
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
    //public var pinObserver: AnyObserver<String?> { return pinSubject.asObserver() }
    //public var termsAndConditionsActionObserver: AnyObserver<Void> { return termsAndConditionsActionSubject.asObserver() }
    //public var requestForgotPINObserver: AnyObserver<OTPVerificationResult> { return requestForgotPINSubject.asObserver() }
    
    // MARK: - Outputs - Implementation of "outputs" protocol
    public var pinText: Observable<String?> { return pinTextSubject.map({ String($0?.map{ _ in Character("\u{25CF}") } ?? []) }).asObservable() }
    public var error: Observable<String> { return errorSubject.asObservable() }
    public var result: Observable<String> { return resultSubject.asObservable() }
    public var pinValid: Observable<Bool> { return pinValidSubject.asObservable() }
    public var back: Observable<Void> { return backSubject.asObservable() }
    public var forgotPasscode: Observable<Void> { return forgotPasscodeSubject.asObservable() }
    public var loader: Observable<Bool> { return loaderSubject.asObservable() }
    public var localizedText: Observable<LocalizedText> { return self.localizedTextSubject.asObservable() }
    
    //public var passcodeSuccess: Observable<String> { return passcodeSuccessSubject.asObservable() }
    //public var headingText: Observable<String?> { return headingTextSubject.asObservable() }
    //public var termsAndConditionsText: Observable<NSAttributedString?> { return termsAndConditionsSubject.asObservable() }
    //public var actionTitle: Observable<String?> { return actionTitleSubject.asObservable() }
    //public var shake: Observable<Void> { return shakeSubject.asObservable() }
    //public var enableBack: Observable<(Bool, BackButtonType)> { return enableBackSubject.asObservable() }
    //public var username: Observable<String> { return usernameSubject.asObservable() }
    //public var backImage: Observable<BackButtonType> { return backImageSubject.asObservable() }
    //public var forgotPasscodeEnable: Observable<Bool?> { return forgotPasscodeEnableSubject.asObservable() }
    //public var requestForgotPIN: Observable<OTPVerificationResult> { return requestForgotPINSubject.asObservable() }
    //public var verifyForgotPIN: Observable<Void> { return verifyForgotPINSubject.asObservable() }
    //public var openTermsAndCondtions: Observable<Void> { termsAndConditionsActionSubject.asObservable() }
    //public var hideNavigationBar: Observable<Bool>{ return hideNavigationBarSubject.asObservable() }
    
    // MARK: - Subjects
    /*
     Define only those Subject required to satisfy inputs and outputs.
     All subjects should be internal unless needed otherwise
     */
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
    
    //internal let passcodeSuccessSubject = PublishSubject<String>()
    //public let headingTextSubject = BehaviorSubject<String?>(value: nil)
    //public let termsAndConditionsSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    //internal let termsAndConditionsActionSubject = PublishSubject<Void>()
    //public let actionTitleSubject = BehaviorSubject<String?>(value: nil)
    //public let shakeSubject = PublishSubject<Void>()
    //public let pinSubject = BehaviorSubject<String?>(value: nil)
    //public let enableBackSubject = BehaviorSubject<(Bool, BackButtonType)>(value: (true, .backCircled))
    //internal let usernameSubject = BehaviorSubject<String>(value: "")
    //public let backImageSubject = BehaviorSubject<BackButtonType>(value: .backCircled)
    //internal let forgotPasscodeEnableSubject = BehaviorSubject<Bool?>(value: nil)
    //internal let requestForgotPINSubject = PublishSubject<OTPVerificationResult>()
    //internal let verifyForgotPINSubject = PublishSubject<Void>()
    //internal let hideNavigationBarSubject = BehaviorSubject<Bool>(value: true)
    
    // MARK: Internal Properties and ViewModels
    private let repository: LoginRepository
    private let pinRange: ClosedRange<Int>
    private let disposeBag = DisposeBag()
    private let credentialsManager: CredentialsStoreType!
    private let username: String!
    private let sessionCreator: SessionProviderType!
    
    // MARK: - Init
    init( repository: LoginRepository,
          credentialsManager: CredentialsStoreType,
          //username: String,
          sessionCreator: SessionProviderType,
          pinRange: ClosedRange<Int> = 4...6) {
        
        self.repository = repository
        self.pinRange = pinRange
        self.credentialsManager = credentialsManager
        self.username = credentialsManager.getUsername() ?? ""
        self.sessionCreator = sessionCreator
        
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
        
        /*
        actionSubject.withLatestFrom(pinText)
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(true) })
            .flatMap { pinCode in
                self.repository.authenticate(username: "00923331599998", password: pinCode ?? "", deviceId: "123")
            }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .subscribe(onNext: { result in
                print(result)
            }).disposed(by: disposeBag) */
        bindUserAuthentication(repository: repository)
    }
    
    public func createTermsAndConditions(text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        let termsAndConditions = text.components(separatedBy: "\n").last ?? ""
        attributedText.addAttribute(.foregroundColor, value: UIColor.blue/*appColor(ofType: .primary)*/, range: NSRange(location: text.count - termsAndConditions.count, length: termsAndConditions.count))
        attributedText.addAttribute(.foregroundColor, value: UIColor.darkGray /*appColor(ofType: .greyDark)*/, range: NSRange(location: 0, length: text.count - termsAndConditions.count))
        return attributedText
    }
}


fileprivate extension VerifyPasscodeViewModel {
    func bindUserAuthentication(repository: LoginRepository) {
        
        let loginRequest = actionSubject.withLatestFrom(pinTextSubject)
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(true) })
            .flatMap { [unowned self] pinCode in
                self.repository.authenticate(username: self.username ?? "", password: pinCode ?? "", deviceId: UIDevice.deviceID)
            }
            .debug()
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()
        
        let loginResponse = loginRequest.elements().unwrap().map { $0["id_token"] ?? "" }.unwrap()

        //loginResponse.filter{ !$0.isEmpty }
         //   .do(onNext: { elem in
         //       print(elem)
         //   })
         //   .bind(to: resultSubject)
        //  .disposed(by: disposeBag)
        
        loginResponse.filter{ !($0.isEmpty ) }
            .map{ self.sessionCreator.makeUserSession(jwt: $0) }
            .do(onNext: { [weak self] session in
                self?.loaderSubject.onNext(false)
                //self?.resultSubject.onNext(PasscodeResult.dashboard(session: session))
            })
            .withLatestFrom(pinTextSubject).unwrap()
            .do(onNext: { [unowned self] passcode in
                self.credentialsManager.secureCredentials(username: self.username, passcode: passcode)
            }).bind(to: resultSubject)
            .disposed(by: disposeBag)
        
            //.subscribe(onNext: {
            //if !self.credentialsManager.isCredentialsAvailable {
            //}
            //}).disposed(by: disposeBag)
        
        //.withLatestFrom(Observable.combineLatest(usernameSubject, passcodeSubject))
        //.map{ Credentials(username: $0.0, passcode: $0.1) }
        
        let apiError = loginRequest.errors().withUnretained(self).share()
        let invalidCredentials = apiError.map({ $0.0.inValidCredentials(error: $0.1) })  // invalidCredentials
            .filter({ $0.0 == true })
            .map({ $0.1 })
        let errorOther = apiError.filter({ !$0.0.isErrorAuthFailure(error: $0.1) && !$0.0.isErrorAccountLocked(error: $0.1) })
            .map({ $0.1.localizedDescription }) // errorSubject
        let optBlocked = apiError.filter{ $0.0.isOTPBlocked(error: $0.1) }
            .map{ ($0.1 as? AuthenticationError)?.errorDescription }.unwrap() // OTP Blocked: Alert message
        //let IncorrectAttemptsReached = apiError.filter { $0.0.isErrorAuthFailure(error: $0.1) }
        //    .map { $0.0.getIncorrectAttemptsHoldTime(error: $0.1) } // Timer Invervels
        let accountLocked = apiError.filter { $0.0.isErrorAccountLocked(error: $0.1) }
            .map({ $0.1.localizedDescription })
        let accountFreezed = apiError.filter { $0.0.isErrorAccountFreeze(error: $0.1) }
            .map { $0.0.getFreezeErrorDescription(error: $0.1) }.unwrap()
        
        Observable.merge(invalidCredentials, errorOther, optBlocked, accountLocked, accountFreezed)
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
        
        /* timerSubject
            .map { [unowned self] timeInterval -> String? in
                if timeInterval == 0 { return nil }
                return self.timeString(prefix:  "screen_verify_passcode_text_incorrect_attempts".localized, timeInterval: timeInterval) }
            .bind(to: incorrectAttemptsReachedSubject)
            .disposed(by: disposeBag)
        
        
        timerSubject.filter { $0 == 0 }.map { _ in () }.bind(to: clearPasscodeSubject).disposed(by: disposeBag)
        
        clearPasscodeSubject.map { _ in "" }.bind(to: passcodeSubject).disposed(by: disposeBag)
        
        validPasscodeSubject.bind(to: isConfirmEnabledSubject).disposed(by: disposeBag) */
        
        // Combined error handling
        /* Observable.from([
            incorrectAttemptsReachedError.map { _ in true },
            accountLockedError.map { _ in true },
            accountFreezeError.map { _ in true },
            isExistingAccountBlockedSubject,
            timerSubject.filter { $0 == 0 }.map { _ in false }
        ]).merge().bind(to: isKeypadLockedSubject).disposed(by: disposeBag) */
    
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
    
    /* func startTimer(duration: TimeInterval) -> Disposable {
        let timer = Observable<NSInteger>.timer(RxTimeInterval.microseconds(0), period: RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        return timer.do(onNext: { [weak self] timer in
            if duration - TimeInterval(timer) < 0 {
                self?.timerDisposable?.dispose()
            }
        }).map { duration - TimeInterval($0) }.bind(to: timerSubject)
    } */
    
    func timeString(prefix: String, timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval/60.0)
        let seconds = Int(timeInterval) % 60
        
        return String.init(format: "%@ %02d:%02d", prefix, minutes, seconds)
    }

}
