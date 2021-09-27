//
// VerifyPasscodeViewModel.swift
// Alamofire
//
// Created by Sarmad on 20/09/2021.
//

import RxSwift
import YAPCore

public enum PasscodeVerificationResult {
    case waiting
    case allowed
    case onboarding
    case blocked
    case dashboard
    case cancel
    case logout
}

struct VerificationResponse {
    var optRequired: Bool = false
    var session: Session!
}

protocol VerifyPasscodeViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var actionObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var forgotPasscodeObserver: AnyObserver<Void> { get }
}

protocol VerifyPasscodeViewModelOutputs {
    typealias LocalizedText = (heading: String, signIn: String, forgot: String)

    var loginResult: Observable<PasscodeVerificationResult> { get }
    var result: Observable<ResultType<VerificationResponse>> { get }
    var pinValid: Observable<Bool> { get }
    var pinText: Observable<String?> { get }
    var error: Observable<String> { get }
    var back: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var localizedText: Observable<LocalizedText> { get }
    var shake: Observable<Void> { get }
}

protocol VerifyPasscodeViewModelType {
    typealias OnLoginClosure = (Session, inout AccountProvider?) -> Void

    var inputs: VerifyPasscodeViewModelInputs { get }
    var outputs: VerifyPasscodeViewModelOutputs { get }
}

open class VerifyPasscodeViewModel: VerifyPasscodeViewModelType,
                                    VerifyPasscodeViewModelInputs,
                                    VerifyPasscodeViewModelOutputs {

    // MARK: - Properties
    var inputs: VerifyPasscodeViewModelInputs { return self }
    var outputs: VerifyPasscodeViewModelOutputs { return self }

    // MARK: - Inputs - Implementation of "inputs" protocol
    var keyPressObserver: AnyObserver<String> { return keyPressSubject.asObserver() }
    var actionObserver: AnyObserver<Void> { return actionSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var forgotPasscodeObserver: AnyObserver<Void> { return forgotPasscodeSubject.asObserver() }

    // MARK: - Outputs - Implementation of "outputs" protocol
    var pinText: Observable<String?> { return pinTextSubject
        .map({ String($0?.map{ _ in Character("\u{25CF}") } ?? []) })
        .asObservable()
    }
    var error: Observable<String> { return errorSubject.asObservable() }
    var loginResult: Observable<PasscodeVerificationResult> { return loginResultSubject.asObservable() }
    var result: Observable<ResultType<VerificationResponse>> { return resultSubject.asObservable() }
    var pinValid: Observable<Bool> { return pinValidSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var forgotPasscode: Observable<Void> { return forgotPasscodeSubject.asObservable() }
    var loader: Observable<Bool> { return loaderSubject.asObservable() }
    var localizedText: Observable<LocalizedText> { return self.localizedTextSubject.asObservable() }
    var shake: Observable<Void> { return shakeSubject.asObservable() }

    // MARK: - Subjects

    fileprivate let loginResultSubject = PublishSubject<PasscodeVerificationResult>()
    fileprivate let resultSubject = PublishSubject<ResultType<VerificationResponse>>()
    fileprivate let pinValidSubject = BehaviorSubject<Bool>(value: false)
    fileprivate let pinTextSubject = BehaviorSubject<String?>(value: nil)
    fileprivate let errorSubject = PublishSubject<String>()
    fileprivate let actionSubject = PublishSubject<Void>()
    fileprivate let keyPressSubject = PublishSubject<String>()
    fileprivate let backSubject = PublishSubject<Void>()
    fileprivate let forgotPasscodeSubject = PublishSubject<Void>()
    fileprivate let loaderSubject = PublishSubject<Bool>()
    fileprivate let localizedTextSubject: BehaviorSubject<LocalizedText>
    fileprivate let shakeSubject = PublishSubject<Void>()

    // MARK: Internal Properties and ViewModels
    private let repository: LoginRepository
    private let pinRange: ClosedRange<Int>
    private let disposeBag = DisposeBag()
    private let credentialsManager: CredentialsStoreType!
    private let sessionCreator: SessionProviderType!
    private let username: String
    private var isUserBlocked: Bool = false

    private let onLoginClosure: OnLoginClosure

    private var session: Session!
    private var accountProvider: AccountProvider?

    // MARK: - Init
    init( username: String,
          isUserBlocked: Bool = false,
          repository: LoginRepository,
          credentialsManager: CredentialsStoreType,
          sessionCreator: SessionProviderType,
          pinRange: ClosedRange<Int> = 4...6,
          onLogin: @escaping OnLoginClosure) {

        self.username = username
        self.isUserBlocked = isUserBlocked
        self.repository = repository
        self.pinRange = pinRange
        self.credentialsManager = credentialsManager
        self.sessionCreator = sessionCreator
        self.onLoginClosure = onLogin

        self.localizedTextSubject = BehaviorSubject(value: (
            "screen_enter_passcode_display_text_title".localized,
            "screen_create_passcode_button_signin".localized,
            "screen_create_passcode_button_forgot_passcode".localized
        ))

        backSubject.do(onNext: { [weak self] in
            self?.credentialsManager.setRemembersId(false)
            self?.credentialsManager.clearUsername()
        }).flatMap({ [unowned self] _ in
            self.repository.logout(deviceUUID: UIDevice.deviceID)
        })
        .subscribe()
        .disposed(by: disposeBag)

        let pinText = pinTextSubject.distinctUntilChanged().share()

        pinText.map({ [unowned self] in ($0 ?? "").count >= self.pinRange.lowerBound })
            .bind(to: pinValidSubject)
            .disposed(by: disposeBag)

        keyPressSubject.withLatestFrom(Observable.combineLatest(keyPressSubject, pinTextSubject))
            .do(onNext: { [unowned self] _ in errorSubject.onNext("") })
            .debug("PINOB", trimOutput: false)
            .map { keyStroke, pin -> String in
                var pin = pin ?? ""
                if keyStroke == "\u{08}" {
                    if !pin.isEmpty { pin.removeLast() }
                } else {
                    if pin.count < pinRange.upperBound { pin += keyStroke }
                }
                return pin
            }.bind(to: pinTextSubject).disposed(by: disposeBag)

        bindUserAuthentication(repository: repository)
    }

    func createTermsAndConditions(text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        let termsAndConditions = text.components(separatedBy: "\n").last ?? ""
        attributedText.addAttribute(.foregroundColor,
                                    value: UIColor.blue,
                                    range: NSRange(location: text.count - termsAndConditions.count,
                                                   length: termsAndConditions.count))
        attributedText.addAttribute(.foregroundColor,
                                    value: UIColor.darkGray,
                                    range: NSRange(location: 0,
                                                   length: text.count - termsAndConditions.count))
        return attributedText
    }
}

fileprivate extension VerifyPasscodeViewModel {
    func bindUserAuthentication(repository: LoginRepository) {

        let loginRequest = actionSubject.withLatestFrom(pinTextSubject).unwrap()
            .withUnretained(self)
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(true) })
            .flatMap {
                $0.0.repository.authenticate(username: $0.0.username, password: $0.1, deviceId: UIDevice.deviceID)
            }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        let loginResponse = loginRequest.elements().unwrap().map { $0["id_token"] ?? "" }

        loginResponse
            .withLatestFrom(self.pinTextSubject).withLatestFrom(pinTextSubject).unwrap().withUnretained(self)
            .subscribe(onNext: { $0.0.credentialsManager.secureCredentials(username: $0.0.username, passcode: $0.1 ) })
            .disposed(by: disposeBag)

        loginResponse.withLatestFrom(pinTextSubject).unwrap().withUnretained(self)
            .subscribe(onNext: { $0.0.credentialsManager.secureCredentials(username: $0.0.username, passcode: $0.1 ) })
            .disposed(by: disposeBag)

        loginResponse
            .filter{ $0?.isEmpty ?? true }
            .map({ _ in ResultType.success(VerificationResponse(optRequired: true)) })
            .bind(to: resultSubject)
            .disposed(by: disposeBag)

        let loginResponseSuccess = loginResponse.unwrap().filter{ !($0.isEmpty) }

        loginResponseSuccess.subscribe(onNext: { token in
            self.session = self.sessionCreator.makeUserSession(jwt: token)
            self.onLoginClosure(self.session, &self.accountProvider)
            self.refreshAccount()
        }).disposed(by: disposeBag)

        let apiError = loginRequest.errors()
            .withUnretained(self)
            .share()

        apiError.filter({ !$0.0.isErrorAuthFailure(error: $0.1) && !$0.0.isErrorAccountLocked(error: $0.1) })
            .map{ _ in () }
            .bind(to: shakeSubject)
            .disposed(by: disposeBag)

        let invalidCredentials = apiError.map({ $0.0.inValidCredentials(error: $0.1) })
            .filter({ $0.0 == true })
            .map({ $0.1 })
        let optBlocked = apiError.filter{ $0.0.isOTPBlocked(error: $0.1) }
            .map{ ($0.1 as? AuthenticationError)?.errorDescription }.unwrap()

        let accountLocked = apiError.filter { $0.0.isErrorAccountLocked(error: $0.1) }
            .map({ $0.1.localizedDescription })
        let accountFreezed = apiError.filter { $0.0.isErrorAccountFreeze(error: $0.1) }
            .map { $0.0.getFreezeErrorDescription(error: $0.1) }.unwrap()

        Observable.merge(invalidCredentials, optBlocked, accountLocked, accountFreezed)
            .do(onNext: { [weak self] _ in self?.pinTextSubject.onNext("") })
            .bind(to: errorSubject)
            .disposed(by: disposeBag)

    }

    private func refreshAccount() {
        guard let accountProvider = accountProvider else {
            return assertionFailure()
        }

        accountProvider.currentAccount
            .unwrap()
            .take(1)
            .subscribe(onNext: { account in
                if account.isWaiting {
                    self.loginResultSubject.onNext(.waiting)
                } else if (account.iban ?? "").isEmpty {
                    self.loginResultSubject.onNext(.allowed)
                } else if account.isOTPBlocked {
                    self.loginResultSubject.onNext(.blocked)
                } else {
                    self.loginResultSubject.onNext(.dashboard)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Helpers
extension UIDevice {
    static var deviceID: String { UIDevice.current.identifierForVendor?.uuidString ?? "" }
}

fileprivate extension VerifyPasscodeViewModel {

    func inValidCredentials(error: Error) -> (Bool, String) {
        if case let AuthenticationError.serverError(code, message) = error {
            return (code == 301, message)
        }
        return (false, "Invalid passcode")
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
        let minutes = Int(timeInterval / 60.0)
        let seconds = Int(timeInterval) % 60
        return String(format: "%@ %02d: %02d", prefix, minutes, seconds)
    }

}
