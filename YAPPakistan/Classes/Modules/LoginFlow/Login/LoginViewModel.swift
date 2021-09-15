//
//  LoginViewModel.swift
//  App
//
//  Created by Uzair on 18/06/2021.
//

import Foundation
import RxSwift
import PhoneNumberKit
import YAPComponents

protocol LoginViewModelInputs {
    var mobileNumberObserver: AnyObserver<String> { get }
    var rememberIdObserver: AnyObserver<Bool> { get }
    var onSignIn: AnyObserver<Void> { get }
    var onSignUp: AnyObserver<Void> { get }
    var backButton: AnyObserver<Void> { get }
}

protocol LoginViewModelOutputs {
    var username: Observable<String> { get }
    var validUsername: Observable<String> { get }
    var rememberId: Observable<Bool> { get }
    var signIn: Observable<Void> { get }
    var signUp: Observable<Void> { get }
    var back: Observable<Void> { get }
    //    var isValidInput: Observable<AppRoundedTextFieldValidation> { get }
    var activateSignInButton: Observable<Bool> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var success: Observable<(String, Bool)> { get }
    var endEditing: Observable<Bool> { get }
    var validation: Observable<AppRoundedTextFieldValidation> { get }
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {
    
    var inputs: LoginViewModelInputs { return self }
    var outputs: LoginViewModelOutputs { return self }
    
    private let usernameSubject = BehaviorSubject<String>(value: "")
    private let validUsernameSubject = BehaviorSubject<String>(value: "")
    private let rememberIdSubject = BehaviorSubject<Bool>(value: true)
    private let signInSubject = PublishSubject<Void>()
    private let signUpSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    private let loadingSubject = PublishSubject<Bool>()
    private let successSubject = PublishSubject<(String, Bool)>()
    private let endEditingSubject = PublishSubject<Bool>()
    private let activateSignInButtonSubject = BehaviorSubject<Bool>(value: false)
    private let validationSubject = BehaviorSubject<AppRoundedTextFieldValidation>(value: .neutral)
    
    var mobileNumberObserver: AnyObserver<String> { return usernameSubject.asObserver()}
    var rememberIdObserver: AnyObserver<Bool> { return rememberIdSubject.asObserver()}
    var onSignIn: AnyObserver<Void> { return signInSubject.asObserver()}
    var onSignUp: AnyObserver<Void> { return signUpSubject.asObserver()}
    var backButton: AnyObserver<Void> { return backSubject.asObserver()}
    
    var username: Observable<String> { return usernameSubject.asObserver()}
    var validUsername: Observable<String> { return validUsernameSubject.asObservable() }
    var rememberId: Observable<Bool> { return rememberIdSubject.asObservable() }
    var signIn: Observable<Void> { return signInSubject.asObservable()  }
    var signUp: Observable<Void> { return signUpSubject.asObservable()  }
    var back : Observable<Void> { return backSubject.asObservable()  }
    var loading: Observable<Bool> { return loadingSubject.asObservable() }
    var error: Observable<String> { return errorSubject.asObservable()   }
    var success: Observable<(String, Bool)> { return successSubject.asObservable() }
    var endEditing: Observable<Bool> { return endEditingSubject.asObservable() }
    var validation: Observable<AppRoundedTextFieldValidation> { validationSubject.asObservable() }
    var activateSignInButton: Observable<Bool> { return activateSignInButtonSubject.asObservable() }
    
    //properties
    private let disposeBag: DisposeBag = DisposeBag()
    //private let credentialsManager: CredentialsManager
    //private let phoneNumberKit = PhoneNumberKit()
    //private let repository: LoginRepositoryType
    
    init(/*repository: LoginRepositoryType,
         credentialsManager: CredentialsManager = CredentialsManager()*/) {
        /*
        self.repository = repository
        self.credentialsManager = credentialsManager
        
        AppTheme.shared.colorTheme = .yap
        
        let phoneNumberKit = self.phoneNumberKit
        
        let isValid = usernameSubject.map{ username -> Bool in
            if username.isPhoneNumberType {
                return (try? phoneNumberKit.parse(username, withRegion: "AE", ignoreType: true)) != nil
            } else {
                return ValidationService.shared.validateEmail(username)
            } }
            .share()
        
        isValid.map{ $0 ?  .valid : .neutral }
            .bind(to: validationSubject)
            .disposed(by: disposeBag)
        
        isValid.bind(to: activateSignInButtonSubject).disposed(by: disposeBag)
        
        usernameSubject
            .map{ username -> String in
                var newUserName = username
                if let phone = try? phoneNumberKit.parse(username, withRegion: "AE", ignoreType: true) {
                    newUserName = phoneNumberKit.format(phone, toType: .national)
                        .components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    newUserName = newUserName.hasPrefix("0") ? newUserName.subString(1, length: newUserName.count) : newUserName
                }
                return newUserName }
            .bind(to: validUsernameSubject)
            .disposed(by: disposeBag)
        
        
        let verifyUserRequest = signInSubject.withLatestFrom(validUsernameSubject)
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { self.repository.verifyUser(username: $0) }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()
        
        let isVerificationSuccess = verifyUserRequest.elements().share(replay: 1, scope: .whileConnected)
        let verificationErrorMessageKey = "screen_sign_in_display_text_error_text"
        let verificationErrorMessage =  verificationErrorMessageKey.localized
        isVerificationSuccess.filter { $0 == true }.withLatestFrom(validUsernameSubject)
            .do(onNext: {
                if credentialsManager.remembersId ?? true {
                    _ = credentialsManager.secure(username: $0)
                }
            })
            .map { ($0, false) }.bind(to: successSubject).disposed(by: disposeBag)
        isVerificationSuccess.filter { $0 == false }.map { _ in verificationErrorMessage }.bind(to: errorSubject).disposed(by: disposeBag)
        
        let apiError = verifyUserRequest.errors().share()
        apiError.filter { [unowned self] error in !self.isErrorUserBlocked(error) }.map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)
        apiError.filter { [unowned self] error in self.isErrorUserBlocked(error) }.withLatestFrom(validUsername).map { ($0, true) }.bind(to: successSubject).disposed(by: disposeBag)
        
        rememberUsername(credentialsManager)
        
        let credentialsManager = CredentialsManager()
        guard let username = credentialsManager.getUsername() else { return }
        
        usernameSubject.onNext(username)
        
        guard credentialsManager.isCredentialsAvailable else {
            _ = credentialsManager.clearUsername()
            return
        } */
    }
    
    func isErrorUserBlocked(_ error: Error) -> Bool {
        if case let NetworkErrors.internalServerError(internalError) = error {
            return internalError?.errors.first?.code == "AD-10018"
        }
        return false
    }
}

private extension LoginViewModel {
    func rememberUsername(_ credentialsManager: CredentialsManager) {
        rememberIdSubject.onNext(credentialsManager.remembersId ?? true)
        
        rememberIdSubject
            .do(onNext: {
                if !$0 {
                   // _ = credentialsManager.clearUsername()
                }
            })
            .subscribe(onNext: { credentialsManager.setRemembersId($0) })
            .disposed(by: disposeBag)
    }
}

