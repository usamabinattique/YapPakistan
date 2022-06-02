//
//  ChangePasscodeViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 27/04/2022.
//

import Foundation
import YAPComponents
import RxSwift

enum ChangePasscodeInputState {
    case currentPasscode
    case newPasscode
    case reenterNewPasscode
}

protocol ChangePasscodeViewModelInputs {
    var keyPressObserver: AnyObserver<String> { get }
    var actionObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var forgotPasscodeObserver: AnyObserver<Void> { get }
    var biometricObserver: AnyObserver<Void> { get }
}

protocol ChangePasscodeViewModelOutputs {
    typealias LocalizedText = (heading: String, signIn: String, forgot: String)

    var loginResult: Observable<PasscodeVerificationResult> { get }
    var pinValid: Observable<Bool> { get }
    var pinText: Observable<String?> { get }
    var error: Observable<String> { get }
    var back: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var localizedText: Observable<LocalizedText> { get }
    var shake: Observable<Void> { get }
    var forgot: Observable<Void> { get }
    var biometryEnabled: Observable<Bool> { get }
    var success : Observable<Void> { get }
}

protocol ChangePasscodeViewModelType {
    //typealias OnLoginClosure = (Session, inout AccountProvider?) -> Void

    var inputs: ChangePasscodeViewModelInputs { get }
    var outputs: ChangePasscodeViewModelOutputs { get }
}

open class ChangePasscodeViewModel: ChangePasscodeViewModelType,
                                    ChangePasscodeViewModelInputs,
                                    ChangePasscodeViewModelOutputs {

    // MARK: - Properties
    var inputs: ChangePasscodeViewModelInputs { return self }
    var outputs: ChangePasscodeViewModelOutputs { return self }

    // MARK: - Inputs - Implementation of "inputs" protocol
    var keyPressObserver: AnyObserver<String> { return keyPressSubject.asObserver() }
    var actionObserver: AnyObserver<Void> { return actionSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var forgotPasscodeObserver: AnyObserver<Void> { return forgotPasscodeSubject.asObserver() }
    var biometricObserver: AnyObserver<Void> { return biometricSubject.asObserver() }

    // MARK: - Outputs - Implementation of "outputs" protocol
    var pinText: Observable<String?> { return pinTextSubject
        .map({ String($0?.map{ _ in Character("\u{25CF}") } ?? []) })
        .asObservable()
    }
    var error: Observable<String> { return errorSubject.asObservable() }
    var loginResult: Observable<PasscodeVerificationResult> { return loginResultSubject.asObservable() }
    //var result: Observable<ResultType<VerificationResponse>> { return resultSubject.asObservable() }
    var pinValid: Observable<Bool> { return pinValidSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var forgotPasscode: Observable<Void> { return forgotPasscodeSubject.asObservable() }
    var loader: Observable<Bool> { return loaderSubject.asObservable() }
    var localizedText: Observable<LocalizedText> { return self.localizedTextSubject.asObservable() }
    var shake: Observable<Void> { return shakeSubject.asObservable() }
    var forgot: Observable<Void> { return forgotPasscodeSubject.asObservable() }
    var biometryEnabled: Observable<Bool> { return biometryEnabledSubject.asObserver() }
    var success : Observable<Void> { return pinChangeSuccessSubject.asObserver() }

    // MARK: - Subjects

    fileprivate let loginResultSubject = PublishSubject<PasscodeVerificationResult>()
    //fileprivate let resultSubject = PublishSubject<ResultType<VerificationResponse>>()
    fileprivate let pinValidSubject = BehaviorSubject<Bool>(value: false)
    fileprivate let pinTextSubject = BehaviorSubject<String?>(value: nil)
    fileprivate let errorSubject = PublishSubject<String>()
    fileprivate let actionSubject = PublishSubject<Void>()
    fileprivate let keyPressSubject = PublishSubject<String>()
    fileprivate let backSubject = PublishSubject<Void>()
    fileprivate let forgotPasscodeSubject = PublishSubject<Void>()
    fileprivate let loaderSubject = PublishSubject<Bool>()
    fileprivate var localizedTextSubject: BehaviorSubject<LocalizedText>
    fileprivate let shakeSubject = PublishSubject<Void>()
    fileprivate let biometryEnabledSubject = BehaviorSubject<Bool>(value: false)
    fileprivate let biometricSubject = PublishSubject<Void>()
    fileprivate let pinChangeSuccessSubject = PublishSubject<Void>()
    
    fileprivate let currentPINCOdeTextSubject = BehaviorSubject<String>(value: "")
    fileprivate let newPINCOdeTextSubject = BehaviorSubject<String>(value: "")
    fileprivate let confirmNewPINCOdeTextSubject = BehaviorSubject<String>(value: "")
    fileprivate let resetPINTokenSubject = BehaviorSubject<String>(value: "")

    // MARK: Internal Properties and ViewModels
    private let repository: LoginRepositoryType
    private let pinRange: ClosedRange<Int>
    private let disposeBag = DisposeBag()
    //private let credentialsManager: CredentialsStoreType!
    //private let sessionCreator: SessionProviderType!
    //private let username: String
    private var isUserBlocked: Bool = false
    private var passcodeInputState: ChangePasscodeInputState = .currentPasscode

    //private let onLoginClosure: OnLoginClosure

//    private var session: Session!
//    private var accountProvider: AccountProvider?
    
    deinit {
        print(self)
    }

    // MARK: - Init
    init(
          repository: LoginRepositoryType,
          pinRange: ClosedRange<Int> = 4...4) {

        
        self.repository = repository
        self.pinRange = pinRange
        //self.credentialsManager = credentialsManager
        //self.sessionCreator = sessionCreator
        //self.onLoginClosure = onLogin

//        self.biometricsManager = biometricsManager
//        self.notificationManager = notificationManager

        self.localizedTextSubject = BehaviorSubject(value: (
            "screen_change_passcode_title".localized,
            "common_button_next".localized,
            "screen_create_passcode_button_forgot_passcode".localized
        ))

//        backSubject.do(onNext: { [weak self] in
//            let user = self?.credentialsManager.getUsername() ?? ""
//            self?.biometricsManager.deleteBiometryForUser(phone: user)
//            self?.notificationManager.deleteNotificationPermission()
//
//            self?.credentialsManager.setRemembersId(false)
//            self?.credentialsManager.clearUsername()
//        }).flatMap({ [unowned self] _ in
//            self.repository.logout(deviceUUID: UIDevice.deviceID)
//        })
//        .subscribe()
//        .disposed(by: disposeBag)

        let pinText = pinTextSubject.distinctUntilChanged().share()

        pinText.map({ [unowned self] in ($0 ?? "").count >= self.pinRange.lowerBound })
            .bind(to: pinValidSubject)
            .disposed(by: disposeBag)

        keyPressSubject
            .filter({ [unowned self] _ in !self.isUserBlocked })
            .withLatestFrom(Observable.combineLatest(keyPressSubject, pinTextSubject))
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [unowned self] in if isUserBlocked {
            errorSubject.onNext("screen_enter_passcode_display_text_user_blocked".localized)
        } }
              
              
              self.pinTextSubject.subscribe(onNext: { pinText in
                  
                  print("PIN Text: \(pinText))")
                  
              }).disposed(by: disposeBag)

              
              //        loginResponse
              //            .withLatestFrom(self.pinTextSubject).withLatestFrom(pinTextSubject).unwrap().withUnretained(self)
              //            .subscribe(onNext: { $0.0.credentialsManager.secureCredentials(username: $0.0.username, passcode: $0.1 ) })
              //            .disposed(by: disposeBag)
              
              
              let verifyReq = actionSubject.withLatestFrom(pinTextSubject).unwrap().withUnretained(self)
                  .subscribe(onNext: { [weak self] value in
                      guard let self = self else { return }
                      
                      if self.passcodeInputState == .currentPasscode {
                          
                          let req = repository.verifyPasscode(passcode: value.1)
                          
                          req.elements().subscribe(onNext: { data in
                              print("Response Data: \(data)");
                              
                              print("PIN TEXT \(value)")
                              self.currentPINCOdeTextSubject.onNext("\(value)")
                              self.resetPINTokenSubject.onNext(data ?? "")
                              self.localizedTextSubject.onNext((heading: "screen_change_new_passcode_title".localized, signIn: "common_button_next".localized, forgot: "common_button_next".localized))
                              self.passcodeInputState = .newPasscode
                              self.pinTextSubject.onNext("")
                              self.shakeSubject.onNext(())
                              
                              
                              
                          } ).disposed(by: self.disposeBag)
                          
                          req.errors().subscribe(onNext: { error in
                              
                              print(error.localizedDescription)
                              self.shakeSubject.onNext(())
                              self.errorSubject.onNext(error.localizedDescription)
                              
                          }).disposed(by: self.disposeBag)
                          
                          
                      }
                      else if self.passcodeInputState == .newPasscode {
                          self.newPINCOdeTextSubject.onNext(value.1)
                          self.localizedTextSubject.onNext((heading: "screen_change_reenter_new_passcode_title".localized, signIn: "common_button_next".localized, forgot: "common_button_next".localized))
                          self.passcodeInputState = .reenterNewPasscode
                          self.pinTextSubject.onNext("")
                          self.shakeSubject.onNext(())
                      }
                      else {
                      
                          
                          print("Next tapped on re-enter screen")
                          self.confirmNewPINCOdeTextSubject.onNext(value.1)
                          
                          
                          let updateRequest = Observable.combineLatest(self.newPINCOdeTextSubject, self.confirmNewPINCOdeTextSubject, self.resetPINTokenSubject).subscribe(onNext: { [weak self] newPassword, confirmNewPassword, newPINToken in
                              
                              
                              guard let self = self else { return }
                              print("New Password: \(newPassword)")
                              print("ConfirmNew Passowrd: \(confirmNewPassword)")
                              print("New PIN TOken: \(newPINToken)")
                              
                              if newPassword != confirmNewPassword {
                                  self.shakeSubject.onNext(())
                                  self.errorSubject.onNext("This doesn't match the previously entered PIN")
                              }
                              else {
                                  
                                  
                                  let req = repository.updatePasscode(newPasscode: newPassword, token: newPINToken)
                                  
                                  req.elements().subscribe(onNext: { [weak self] data in
                                      
                                      print(data)
                                      self?.pinChangeSuccessSubject.onNext(())
                                      
                                  }).disposed(by: self.disposeBag)
                                  
                                  
                                  req.errors().subscribe(onNext: { [weak self] error in
                                      self?.errorSubject.onNext(error.localizedDescription)
                                  }).disposed(by: self.disposeBag)
                              }
                              
                              
                          }).disposed(by: self.disposeBag)
                      }
                      
                      
                      
                      
                      
                  }).disposed(by: disposeBag)
              
              
//        let isBiometricAvailable = credentialsManager.remembersId == true
//            && biometricsManager.isBiometryPermissionPrompt(for: username)
//            && biometricsManager.isBiometrySupported
//            && biometricsManager.isBiometryEnabled(for: username)
//
//        biometryEnabledSubject.onNext(isBiometricAvailable)
//
//        let biometicsAuthenticated = biometricSubject.withLatestFrom(biometryEnabledSubject).filter({ $0 }).map({ _ in () })
//            .flatMap({ () -> Observable<Event<Bool>> in
//                let reason = "screen_verify_passcode_display_text_biometrics_reason".localized + " "
//                    + mask(username: username)
//                return biometricsManager.biometricsAuthenticate(reason: reason).materialize()
//            })
//
//        biometicsAuthenticated.errors().map({ _ in false }).bind(to: biometryEnabledSubject).disposed(by: disposeBag)
//
//        let biometricLoginCredentials = biometicsAuthenticated.elements().filter({ $0 })
//            .withUnretained(self)
//            .map { (username:$0.0.username, password:$0.0.credentialsManager.getPasscode(username: $0.0.username)!) }
//            .share()
//
//        biometricLoginCredentials
//            .map({ $0.password })
//            .bind(to: pinTextSubject)
//            .disposed(by: disposeBag)
//
//        let loginCredentials = actionSubject.withLatestFrom(pinTextSubject).unwrap()
//            .withUnretained(self)
//            .map({ (username:$0.0.username, password:$0.1) })
//
//        bind(with: biometricLoginCredentials)
//        bind(with: loginCredentials)
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

fileprivate extension ChangePasscodeViewModel {
    func bind(with credentials: Observable<(username: String, password: String)>) {

//        let loginRequest = credentials.withUnretained(self)
//            .do(onNext: { $0.0.loaderSubject.onNext(true) })
//            .flatMap { $0.0.repository.authenticate(username: $0.1.username,
//                                                    password: $0.1.password,
//                                                    deviceId: UIDevice.deviceID) }
//            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
//            .share()
//
//        let loginResponse = loginRequest.elements().unwrap().map { $0["id_token"] ?? "" }
//
//        loginResponse
//            .withLatestFrom(self.pinTextSubject).withLatestFrom(pinTextSubject).unwrap().withUnretained(self)
//            .subscribe(onNext: { $0.0.credentialsManager.secureCredentials(username: $0.0.username, passcode: $0.1 ) })
//            .disposed(by: disposeBag)
//
//        loginResponse.withLatestFrom(pinTextSubject).unwrap().withUnretained(self)
//            .subscribe(onNext: { $0.0.credentialsManager.secureCredentials(username: $0.0.username, passcode: $0.1 ) })
//            .disposed(by: disposeBag)
//
//        loginResponse
//            .filter{ $0?.isEmpty ?? true }
//            .map({ _ in ResultType.success(VerificationResponse(optRequired: true)) })
//            .bind(to: resultSubject)
//            .disposed(by: disposeBag)
//
//        let loginResponseSuccess = loginResponse.unwrap().filter{ !($0.isEmpty) }
//
//        loginResponseSuccess.subscribe(onNext: { token in
//            self.session = self.sessionCreator.makeUserSession(jwt: token)
//            self.onLoginClosure(self.session, &self.accountProvider)
//            self.refreshAccount()
//        }).disposed(by: disposeBag)
//
//        let apiError = loginRequest.errors()
//            .withUnretained(self)
//            .share()
//
//        apiError.filter({ !$0.0.isErrorAuthFailure(error: $0.1) && !$0.0.isErrorAccountLocked(error: $0.1) })
//            .map{ _ in () }
//            .bind(to: shakeSubject)
//            .disposed(by: disposeBag)
//
//        let invalidCredentials = apiError.map({ $0.0.inValidCredentials(error: $0.1) })
//            .filter({ $0.0 == true })
//            .map({ $0.1 })
//        let optBlocked = apiError.filter{ $0.0.isOTPBlocked(error: $0.1) }
//            .map{ ($0.1 as? AuthenticationError)?.errorDescription }.unwrap()
//
//        let accountLocked = apiError.filter { $0.0.isErrorAccountLocked(error: $0.1) }
//            .map({ $0.1.localizedDescription })
//        let accountFreezed = apiError.filter { $0.0.isErrorAccountFreeze(error: $0.1) }
//            .map { $0.0.getFreezeErrorDescription(error: $0.1) }.unwrap()
//
//        Observable.merge(invalidCredentials, optBlocked, accountLocked, accountFreezed)
//            .do(onNext: { [weak self] _ in self?.pinTextSubject.onNext("") })
//            .bind(to: errorSubject)
//            .disposed(by: disposeBag)
    }

    private func refreshAccount() {
//        guard let accountProvider = accountProvider else {
//            return assertionFailure()
//        }
//
//        accountProvider.currentAccount.unwrap()
//            .subscribe(onNext: { account in
//                if account.isWaiting {
//                    self.loginResultSubject.onNext(.waiting)
//                } else if (account.iban ?? "").isEmpty {
//                    self.loginResultSubject.onNext(.allowed)
//                } else if account.isOTPBlocked {
//                    self.loginResultSubject.onNext(.blocked)
//                } else {
//                    self.loginResultSubject.onNext(.dashboard)
//                }
//            })
//            .disposed(by: disposeBag)
    }
}



fileprivate extension ChangePasscodeViewModel {

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

//public protocol CurrentPasscodeViewModelOutput {
//    var verificationToken: Observable<String?> { get }
//}
//
//public protocol CurrentPasscodeViewModelType {
//    var currentPasscodeOutputs: CurrentPasscodeViewModelOutput { get }
//}
//
//public class CurrentPasscodeViewModel: PINViewModel, CurrentPasscodeViewModelType, CurrentPasscodeViewModelOutput {
//
//    public var currentPasscodeOutputs: CurrentPasscodeViewModelOutput { self }
//
//    private let verificationTokenSubject = PublishSubject<String?>()
//
//    // MARK: Inputs
//
//    // MARK: Outputs
//    public var verificationToken: Observable<String?> { verificationTokenSubject.asObservable() }
//
//    private let repository: LoginRepositoryType
//
//    init(popable: Bool, pinRange: ClosedRange<Int> = 4...6, repository: LoginRepositoryType, forgotPasscodeEnable: Bool = true) {
//        self.repository = repository
//        super.init(pinRange: pinRange)
//        apiCalling()
//        headingTextSubject.onNext( "screen_current_passcode_display_text_heading".localized)
//        actionTitleSubject.onNext( "screen_current_passcode_display_button_next".localized)
//        enableBackSubject.onNext((popable, .backEmpty))
//        backImageSubject.onNext(.closeEmpty)
//        forgotPasscodeEnableSubject.onNext(forgotPasscodeEnable)
//    }
//}
//
//extension CurrentPasscodeViewModel {
//    fileprivate func apiCalling() {
////        let currentPasscodeRequest = actionSubject
////            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
////            .withLatestFrom(pinSubject).share()
////
////        let currentPasscode = currentPasscodeRequest.unwrap().flatMap {[unowned self] passcode -> Observable<Event<String?>> in
////            //return self.repository.verifyCurrentPasscode(passcode: passcode)
////        }
////        .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
////        .share()
////
////        currentPasscode.elements().withLatestFrom(pinSubject).unwrap().bind(to: resultSubject).disposed(by: disposeBag)
////        currentPasscode.elements().bind(to: verificationTokenSubject).disposed(by: disposeBag)
////
////        currentPasscode.errors()
////            .map {_ in }.bind(to: shakeSubject).disposed(by: disposeBag)
//
//    }
//}
