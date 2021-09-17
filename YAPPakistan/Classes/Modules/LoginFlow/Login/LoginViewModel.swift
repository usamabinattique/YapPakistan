//
// LoginViewModel.swift
// App
//
// Created by Uzair on 18/06/2021.
//

import Foundation
import RxSwift
import RxCocoa
import PhoneNumberKit
import YAPComponents
import YAPCore
import PhoneNumberKit

protocol LoginInOutsViewModel {
    var mobileNumber:BehaviorRelay<String?> { get }
    var rememberMe:BehaviorRelay<Bool> { get }
    var isFirstResponder:BehaviorRelay<Bool> { get }
}

protocol LoginViewModelInputs {
    var signInObserver: AnyObserver<Void> { get }
    var signUpObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<ResultType<Void>> { get }
    var textWillChangeObserver: AnyObserver<TextChange> { get }
}

protocol LoginViewModelOutputs {
    typealias LocalizedText = (heading: String, remember: String, signIn: String, create:String, signUp: String)
    
    var signIn: Observable<Void> { get }
    var signUp: Observable<Void> { get }
    var result:Observable<ResultType<Void>> { get }
    var flag: Observable<String> { get }
    var shouldChange: Bool { get }
    var progress: Observable<Bool> { get }
    var validationResult: Observable<AppRoundedTextFieldValidation> { get }
    var localizedText: Observable<LocalizedText> { get }
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
    var inouts: LoginInOutsViewModel { get }
}

class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs, LoginInOutsViewModel {
    
    var inputs: LoginViewModelInputs { return self }
    var inouts: LoginInOutsViewModel { return self }
    var outputs: LoginViewModelOutputs { return self }
    
    //inouts
    var mobileNumber: BehaviorRelay<String?> = BehaviorRelay(value: "")
    var rememberMe: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isFirstResponder: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    //inputs
    var signInObserver: AnyObserver<Void> { return signInSubject.asObserver() }
    var signUpObserver: AnyObserver<Void> { return signUpSubject.asObserver() }
    var backObserver: AnyObserver<ResultType<Void>> { return resultSubject.asObserver() }
    var textWillChangeObserver: AnyObserver<TextChange> { return textWillChangeSubject.asObserver() }
    
    //outputs
    var signIn: Observable<Void> { return signInSubject.asObservable() }
    var signUp: Observable<Void> { return signUpSubject.asObservable() }
    var flag: Observable<String> {return flagSubject.asObservable()}
    var shouldChange: Bool { return shouldChangeSub }
    var result: Observable<ResultType<Void>> { return resultSubject.asObservable() }
    var progress: Observable<Bool> { return progressSubject.asObservable() }
    var validationResult: Observable<AppRoundedTextFieldValidation> { validationSubject.asObservable() }
    var localizedText: Observable<LocalizedText> { return localizedTextSubject.asObservable() }
    
    //private subjects
    private var shouldChangeSub = true
    private let textWillChangeSubject = PublishSubject<TextChange>()
    private let signInSubject = PublishSubject<Void>()
    private let signUpSubject = PublishSubject<Void>()
    private let flagSubject = BehaviorSubject<String>(value: "")
    private let resultSubject = PublishSubject<ResultType<Void>>()
    private let progressSubject = PublishSubject<Bool>()
    //private let successSubject = PublishSubject<(String, Bool)>()
    private let validationSubject = BehaviorSubject<AppRoundedTextFieldValidation>(value: .neutral)
    private let localizedTextSubject:BehaviorSubject<LocalizedText>
    
    //Properties
    private let disposeBag: DisposeBag = DisposeBag()
    
    private var countryList = [(name: String, code: String, callingCode: String, flag: String)]()
    private var user: OnBoardingUser!
    private let phoneNumberKit = PhoneNumberKit()
    private var isFormatted = false
    private var currentItem = 0
    private let credentialsManager: CredentialsManager
    private let repository: LoginRepository
    
    init( repository: LoginRepository,
          credentialsManager: CredentialsManager,
          user: OnBoardingUser) {
        
        self.repository = repository
        self.credentialsManager = credentialsManager
        self.user = user
        
        self.localizedTextSubject = BehaviorSubject(value:(
            heading: "screen_sign_in_display_text_heading_text".localized,
            remember: "screen_sign_in_display_text_remember_id_text".localized,
            signIn: "screen_sign_in_button_sign_in".localized,
            create: "screen_sign_in_display_text_create_account".localized,
            signUp: "screen_sign_in_button_sign_up".localized
        ))
        
        countryList.append(("Pakistan", "PK", "+92 ", "PK"))
        
        flagSubject.onNext(countryList.first?.flag ?? "")
        mobileNumber.accept(countryList.first?.callingCode ?? "")
        
        let selectNumber = mobileNumber.distinctUntilChanged().debug("HHHH", trimOutput: true).do(onNext: {[unowned self] in
                                                                                                    self.user.mobileNo.formattedValue = $0 }
        ).map { [unowned self] in
            self.formatePhoneNumber($0 ?? "")
        }.do(onNext: { [unowned self] in
                self.isFormatted = $0.formatted }
        ).share()
        
        selectNumber
            .map { $0.phoneNumber }
            .subscribe(onNext: { string in
                DispatchQueue.main.async { self.mobileNumber.accept(string)}
            }).disposed(by: disposeBag)
        
        selectNumber.map { [unowned self] _ in
            self.isFormatted ? AppRoundedTextFieldValidation.valid:.neutral
        }.merge(with: isFirstResponder.distinctUntilChanged().map { [unowned self] _ in
            self.isFormatted ? AppRoundedTextFieldValidation.valid:.neutral
        }).bind(to: validationSubject)
        .disposed(by: disposeBag)
        
        
        textWillChangeSubject.do(onNext: { [unowned self] (text, range, currentText) in
            let currentText = (currentText ?? "").replacingOccurrences(of: " ", with: "")
            self.shouldChangeSub = (range.location > self.countryList[self.currentItem].callingCode.count-1 && (currentText.count + text.count < 14 || text.count == 0)) && (!self.isFormatted || text.count == 0)
        }).subscribe().disposed(by: disposeBag)
        
        
        let verifyUserRequest = signInSubject.withLatestFrom(mobileNumber.asObservable())
            .map({ ($0 ?? "")
                    .replacingOccurrences(of: "+", with: "00")
                    .replacingOccurrences(of: " ", with: "")
            })
            .do(onNext: {[unowned self] _ in self.progressSubject.onNext(true) })
            .flatMapLatest { self.repository.verifyUser(username: $0) }
            .do(onNext: {[unowned self] _ in self.progressSubject.onNext(false) })
            .share()
        
        let isVerificationSuccess = verifyUserRequest.elements().share(replay: 1, scope: .whileConnected)
        //let verificationErrorMessage = "screen_sign_in_display_text_error_text".localized
        isVerificationSuccess.filter { $0 == true }.withLatestFrom(mobileNumber)
            .do(onNext: {
                if credentialsManager.remembersId ?? true {
                    _ = credentialsManager.secure(passcode: $0 ?? "")
                }
            })
            .map { _ in ResultType.success(()) }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)
        
        let apiError = verifyUserRequest.errors()
        
        apiError.filter { [unowned self] error in !self.isErrorUserBlocked(error) }
            .map { AppRoundedTextFieldValidation.invalid($0.localizedDescription) }
            .bind(to: validationSubject).disposed(by: disposeBag)
        
        apiError.filter { [unowned self] error in self.isErrorUserBlocked(error) }
            .withLatestFrom(mobileNumber)
            .map { _ in ResultType.success(()) }
            .bind(to: resultSubject).disposed(by: disposeBag)
        
        rememberUsername(credentialsManager)
        
        guard let username = credentialsManager.getUsername() else { return }
        
        mobileNumber.accept(username)
        
        guard credentialsManager.isCredentialsAvailable else {
            _ = credentialsManager.clearUsername()
            return
        }
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
        rememberMe.accept(credentialsManager.remembersId ?? true)
        rememberMe
            .do(onNext: {
                if !$0 {
                    //TODO: the method is need to be implemented
                     _ = credentialsManager.clearUsername()
                }
            })
            .subscribe(onNext: { credentialsManager.setRemembersId($0) })
            .disposed(by: disposeBag)
    }
    
    func formatePhoneNumber(_ phoneNumber: String) -> (phoneNumber: String, formatted: Bool) {
        do {
            let pNumber = try phoneNumberKit.parse(phoneNumber)
            let formattedNumber = phoneNumberKit.format(pNumber, toType: .international)
            return (formattedNumber, true)
        } catch {
            debugPrint("error occurred while formatting phone number: \(error.localizedDescription)")
        }
        return (phoneNumber, false)
    }
}

