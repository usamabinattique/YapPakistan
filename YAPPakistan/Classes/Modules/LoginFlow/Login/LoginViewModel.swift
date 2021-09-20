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

protocol LoginViewModelInputs {
    var signInObserver: AnyObserver<Void> { get }
    var signUpObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<ResultType<Void>> { get }
    var textWillChangeObserver: AnyObserver<TextChange> { get }

    var mobileNumberObserver: AnyObserver<String?> { get }
    var rememberMeObserver: AnyObserver<Bool> { get }
    var isFirstResponderObserver: AnyObserver<Bool> { get }
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

    var mobileNumber: Observable<String?> { get }
    var rememberMe: Observable<Bool> { get }
    var isFirstResponder: Observable<Bool> { get }
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {

    var inputs: LoginViewModelInputs { return self }
    var outputs: LoginViewModelOutputs { return self }

    // inputs
    var signInObserver: AnyObserver<Void> { return signInSubject.asObserver() }
    var signUpObserver: AnyObserver<Void> { return signUpSubject.asObserver() }
    var backObserver: AnyObserver<ResultType<Void>> { return resultSubject.asObserver() }
    var textWillChangeObserver: AnyObserver<TextChange> { return textWillChangeSubject.asObserver() }
    var mobileNumberObserver: AnyObserver<String?> { return mobileNumberSubject.asObserver() }
    var rememberMeObserver: AnyObserver<Bool> { return rememberMeSubject.asObserver() }
    var isFirstResponderObserver: AnyObserver<Bool> { return isFirstResponderSubject.asObserver() }

    // outputs
    var signIn: Observable<Void> { return signInSubject.asObservable() }
    var signUp: Observable<Void> { return signUpSubject.asObservable() }
    var flag: Observable<String> {return flagSubject.asObservable()}
    var shouldChange: Bool { return shouldChangeSub }
    var result: Observable<ResultType<Void>> { return resultSubject.asObservable() }
    var progress: Observable<Bool> { return progressSubject.asObservable() }
    var validationResult: Observable<AppRoundedTextFieldValidation> { validationSubject.asObservable() }
    var localizedText: Observable<LocalizedText> { return localizedTextSubject.asObservable() }
    var mobileNumber: Observable<String?> { return mobileNumberSubject.share().asObservable() }
    var rememberMe: Observable<Bool> { return rememberMeSubject.asObservable() }
    var isFirstResponder: Observable<Bool> { isFirstResponderSubject.asObservable() }

    // private subjects
    private var shouldChangeSub = true
    private let textWillChangeSubject = PublishSubject<TextChange>()
    private let signInSubject = PublishSubject<Void>()
    private let signUpSubject = PublishSubject<Void>()
    private let flagSubject = BehaviorSubject<String>(value: "")
    private let resultSubject = PublishSubject<ResultType<Void>>()
    private let progressSubject = PublishSubject<Bool>()
    private let validationSubject = BehaviorSubject<AppRoundedTextFieldValidation>(value: .neutral)
    private let localizedTextSubject:BehaviorSubject<LocalizedText>

    private let mobileNumberSubject: BehaviorSubject<String?> = BehaviorSubject(value: "+92 ")
    private let rememberMeSubject: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    private let isFirstResponderSubject: BehaviorSubject<Bool> = BehaviorSubject(value: false)

    // properties
    private let disposeBag: DisposeBag = DisposeBag()
    private var countryList = [(name: String, code: String, callingCode: String, flag: String)]()
    private var user: OnBoardingUser!
    private let phoneNumberKit = PhoneNumberKit()
    private var isFormatted = false
    private var currentItem = 0
    private let credentialsManager: CredentialsStoreType
    private let repository: LoginRepository

    init( repository: LoginRepository,
          credentialsManager: CredentialsStoreType,
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
        // mobileNumberSubject.onNext(countryList.first?.callingCode ?? "+92 ")

        let selectNumber = mobileNumberSubject
            .distinctUntilChanged()
            .debug("HHHH", trimOutput: true)
            .do(onNext: {[unowned self] in self.user.mobileNo.formattedValue = $0 }
        ).map { [unowned self] in
            self.formatePhoneNumber($0 ?? "")
        }.do(onNext: { [unowned self] in
                self.isFormatted = $0.formatted }
        ).share()

        selectNumber
            .map { $0.phoneNumber }
            .subscribe(onNext: { string in
                DispatchQueue.main.async { self.mobileNumberSubject.onNext(string) }
            }).disposed(by: disposeBag)

        selectNumber.map { [unowned self] _ in
            self.isFormatted ? AppRoundedTextFieldValidation.valid:.neutral
        }.merge(with: isFirstResponderSubject.distinctUntilChanged().map { [unowned self] _ in
            self.isFormatted ? AppRoundedTextFieldValidation.valid:.neutral
        }).bind(to: validationSubject)
        .disposed(by: disposeBag)

        textWillChangeSubject.do(onNext: { [unowned self] (text, range, currentText) in
            let currentText = (currentText ?? "").replacingOccurrences(of: " ", with: "")
            self.shouldChangeSub = (range.location > self.countryList[self.currentItem].callingCode.count-1
                                        && (currentText.count + text.count < 14 || text.count == 0))
                && (!self.isFormatted || text.count == 0)
        }).subscribe().disposed(by: disposeBag)

        let verifyUserRequest = signInSubject.withLatestFrom(mobileNumberSubject.asObservable())
            .map({ ($0 ?? "")
                    .replacingOccurrences(of: "+", with: "00")
                    .replacingOccurrences(of: " ", with: "")
            })
            .do(onNext: {[unowned self] _ in self.progressSubject.onNext(true) })
            .flatMapLatest { self.repository.verifyUser(username: $0) }
            .debug("verifyUser", trimOutput: false)
            .do(onNext: {[unowned self] _ in self.progressSubject.onNext(false) })
            .share()

        verifyUserRequest.elements()
            .filter { $0 == false }
            .map({ _ in AppRoundedTextFieldValidation.invalid("screen_sign_in_display_text_error_text".localized) })
            .bind(to: validationSubject)
            .disposed(by: disposeBag)

        verifyUserRequest.elements().filter { $0 == true }.withLatestFrom(mobileNumberSubject)
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
            .bind(to: validationSubject)
            .disposed(by: disposeBag)

        apiError.filter { [unowned self] error in self.isErrorUserBlocked(error) }
            .withLatestFrom(mobileNumberSubject)
            .map { _ in ResultType.success(()) }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)

        rememberUsername(credentialsManager)

        guard let username = credentialsManager.getUsername() else { return }

        mobileNumberSubject.onNext(username)

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
    func rememberUsername(_ credentialsManager: CredentialsStoreType) {
        rememberMeSubject.onNext(credentialsManager.remembersId ?? true)
        rememberMeSubject
            .do(onNext: {
                if !$0 {
                    // TODO: the method is need to be implemented
                     _ = credentialsManager.clearUsername()
                }
            })
            .subscribe(onNext: { credentialsManager.setRemembersId($0) })
            .disposed(by: disposeBag)
    }

    func formatePhoneNumber(_ phoneNumber: String) -> (phoneNumber: String, formatted: Bool) {

        if let pNumber = try? phoneNumberKit.parse(phoneNumber) {
            let formattedNumber = phoneNumberKit.format(pNumber, toType: .international)
            return (formattedNumber, true)
        }
        return (phoneNumber, false)
    }
}

