//
//  ChangeEmailAddressViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 12/04/2022.
//

import Foundation
import RxSwift
import YAPComponents

typealias EmailVerificationDataProvider = (heading: NSAttributedString, subHeading: NSAttributedString, action: OTPAction)

protocol ChangeEmailAddressViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
    var nextObserver: AnyObserver<Void> { get }
    var emailTextFieldObserver: AnyObserver<String> { get }
    var confirmEmailTextFieldObserver: AnyObserver<String> { get }
    var changeEmailRequestObserver: AnyObserver<Void> { get }
    var validEmailSuccessObserver: AnyObserver<Void> { get }
}

protocol ChangeEmailAddressViewModelOutputs {
    var heading: Observable<String?> { get }
    var back: Observable<Void> { get }
    var nextButtonTitle: Observable<String?> { get }
    var next: Observable<Void> { get }
    var emailTextFieldTitle: Observable<String?> { get }
    var emailTextField: Observable<String> { get }
    var confirmEmailTextFieldTitle: Observable<String?> { get }
    var confirmEmailTextField: Observable<String> { get }
    var descriptionHeading: Observable<String> { get }
    var isEmailValid: Observable<Bool> { get }
    var isConfirmEmailValid: Observable<Bool> { get }
    var activateAction: Observable<Bool> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var success: Observable<String> { get }
    
    var emailValidation: Observable<AppTextField.ValidationState> { get }
    
    var confirmEmailValidation: Observable<AppTextField.ValidationState> { get }
    
    var isEmailMatched: Observable<Bool> { get }
    
    var otpGeneration: Observable<EmailVerificationDataProvider> { get }
    
    var changeEmailRequest: Observable<Void> { get }
    
    var vlidEmail: Observable<Void> { get }
}

protocol ChangeEmailAddressViewModelType {
    var inputs: ChangeEmailAddressViewModelInputs { get }
    var outputs: ChangeEmailAddressViewModelOutputs { get }
}

class ChangeEmailAddressViewModel: ChangeEmailAddressViewModelType, ChangeEmailAddressViewModelInputs, ChangeEmailAddressViewModelOutputs {
    
    let disposeBag = DisposeBag()
    var inputs: ChangeEmailAddressViewModelInputs { return self}
    var outputs: ChangeEmailAddressViewModelOutputs { return self }
    
    internal var headingSubject: BehaviorSubject<String?>
    internal var backSubject = PublishSubject<Void>()
    internal var nextSubject = PublishSubject<Void>()
    internal var nextButtonTitleSubject: BehaviorSubject<String?>
    internal var emailTextFieldSubject = BehaviorSubject<String>(value: "")
    internal var emailTextFieldTitleSubject: BehaviorSubject<String?>
    
    internal var emailValidationSubject = BehaviorSubject<AppTextField.ValidationState>(value: .normal)
    internal var confirmEmailValidationSubject = BehaviorSubject<AppTextField.ValidationState>(value: .normal)
    
    internal var confirmEmailTextFieldSubject = BehaviorSubject<String>(value: "")
    internal var confirmEmailTextFieldTitleSubject: BehaviorSubject<String?>
    internal var descriptionHeadingSubject: BehaviorSubject<String>
    
    internal var activateActionSubject = PublishSubject<Bool>()
    internal var isEmailMatchedSubject = PublishSubject<Bool>()
    
    internal var loadingSubject = PublishSubject<Bool>()
    internal var errorSubject = PublishSubject<String>()
    internal var successSubject = PublishSubject<String>()
    
    internal var changeEmailRequestSubject = PublishSubject<Void>()
    
    internal var validEmailSuccessSubject = PublishSubject<Void>()
    
    internal var otpGenerationSubject = PublishSubject<EmailVerificationDataProvider>()
    
    //inputs
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { return nextSubject.asObserver() }
    var emailTextFieldObserver: AnyObserver<String> { return emailTextFieldSubject.asObserver() }
    var confirmEmailTextFieldObserver: AnyObserver<String> { return confirmEmailTextFieldSubject.asObserver() }
    var changeEmailRequestObserver: AnyObserver<Void> { return changeEmailRequestSubject.asObserver() }
    var validEmailSuccessObserver: AnyObserver<Void> { return validEmailSuccessSubject.asObserver() }
    
    //outputs
    var error: Observable<String> { return errorSubject.asObservable() }
    var success: Observable<String> { return successSubject.asObservable() }
    var loading: Observable<Bool> { return loadingSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var next: Observable<Void> { return nextSubject.asObservable() }
    var heading: Observable<String?> { return headingSubject.asObservable() }
    var emailTextFieldTitle: Observable<String?> { return emailTextFieldTitleSubject.asObservable() }
    var emailTextField: Observable<String> { return emailTextFieldSubject.asObservable() }
    var confirmEmailTextFieldTitle: Observable<String?> { return confirmEmailTextFieldTitleSubject.asObservable() }
    var confirmEmailTextField: Observable<String> { return confirmEmailTextFieldSubject.asObservable() }
    var nextButtonTitle: Observable<String?> { return nextButtonTitleSubject.asObservable() }
    var descriptionHeading: Observable<String> { return descriptionHeadingSubject.asObservable() }
    var emailValidation: Observable<AppTextField.ValidationState> { return emailValidationSubject.asObservable() }
    var confirmEmailValidation: Observable<AppTextField.ValidationState> { return confirmEmailValidationSubject.asObservable() }
    var isEmailValid: Observable<Bool>
    var isConfirmEmailValid: Observable<Bool>
    var isEmailMatched: Observable<Bool> { return isEmailMatchedSubject.asObservable() }
    var activateAction: Observable<Bool> { return activateActionSubject.asObservable() }
    var otpGeneration: Observable<EmailVerificationDataProvider> { return otpGenerationSubject.asObservable() }
    var changeEmailRequest: Observable<Void> { return changeEmailRequestSubject.asObservable() }
    var vlidEmail: Observable<Void> { return validEmailSuccessSubject.asObservable() }
    
    // -- private let profileRepository: ProfileRepository = ProfileRepository()
    fileprivate var email: String
    
    public init(email: String = "") {
        self.email = email
        headingSubject = BehaviorSubject(value:  "screen_change_email_display_text_heading".localized)
        nextButtonTitleSubject = BehaviorSubject(value:  "common_button_next".localized)
        descriptionHeadingSubject = BehaviorSubject(value:  "screen_change_email_display_text_description".localized)
        emailTextFieldTitleSubject = BehaviorSubject(value:  "screen_change_email_display_text_email_title".localized)
        confirmEmailTextFieldTitleSubject = BehaviorSubject(value:  "screen_change_email_display_text_confirm_email_title".localized)
        
        
        emailTextFieldSubject.subscribe(onNext: { valueString in
            print(valueString)
        }).disposed(by: disposeBag)
        
        isEmailValid = emailTextFieldSubject.skip(1).map { ValidationService.shared.validateEmail($0) }
        isEmailValid.map { $0 ? .valid : .invalid }.bind(to: emailValidationSubject).disposed(by: disposeBag)
        
        isConfirmEmailValid = confirmEmailTextFieldSubject.skip(1).map { ValidationService.shared.validateEmail($0) }
        
        let confirmEmailValidation = Observable.combineLatest(emailTextFieldSubject, confirmEmailTextFieldSubject, isEmailValid)
            .map{ email, confirmEmail, emailValid -> AppTextField.ValidationState in
                email == confirmEmail && !email.isEmpty && emailValid ? .valid : email.hasPrefix(confirmEmail) || confirmEmail.isEmpty ? .normal : .invalid }
        
        confirmEmailValidation.bind(to: confirmEmailValidationSubject).disposed(by: disposeBag)
        
        confirmEmailValidation.map{ $0 == .invalid ? "screen_change_email_display_text_confirm_email_diff_error".localized : "" }.bind(to: errorSubject).disposed(by: disposeBag)
        
        isConfirmEmailValid = confirmEmailValidation.map{ $0 == .valid }
        
        Observable.combineLatest(isEmailValid, isConfirmEmailValid).map { $0.0 == true && $0.1 == true }.bind(to: activateActionSubject).disposed(by: disposeBag)
    }
}
