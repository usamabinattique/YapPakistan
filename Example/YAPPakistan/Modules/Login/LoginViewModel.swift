//
//  LoginViewModel.swift
//  YAPPakistan_Example
//
//  Created by Umer on 13/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YAPComponents
import YAPCore

struct RequestResponse {
    var userName: String
    var isBlocked: Bool
}

protocol LoginViewModelInputs {
    var signInObserver: AnyObserver<Void> { get }
    var signUpObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<ResultType<RequestResponse>> { get }
    var textWillChangeObserver: AnyObserver<TextChange> { get }

    var mobileNumberObserver: AnyObserver<String?> { get }
    var rememberMeObserver: AnyObserver<Bool> { get }
    var isFirstResponderObserver: AnyObserver<Bool> { get }
}

protocol LoginViewModelOutputs {
    typealias LocalizedText = (heading: String, remember: String, signIn: String, create: String, signUp: String)

    var signIn: Observable<Void> { get }
    var signUp: Observable<Void> { get }

    var result: Observable<ResultType<RequestResponse>> { get }

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
    var backObserver: AnyObserver<ResultType<RequestResponse>> { return resultSubject.asObserver() }
    var textWillChangeObserver: AnyObserver<TextChange> { return textWillChangeSubject.asObserver() }
    var mobileNumberObserver: AnyObserver<String?> { return mobileNumberSubject.asObserver() }
    var rememberMeObserver: AnyObserver<Bool> { return rememberMeSubject.asObserver() }
    var isFirstResponderObserver: AnyObserver<Bool> { return isFirstResponderSubject.asObserver() }

    // outputs
    var signIn: Observable<Void> { return signInSubject.asObservable() }
    var signUp: Observable<Void> { return signUpSubject.asObservable() }
    var flag: Observable<String> { return flagSubject.asObservable() }
    var shouldChange: Bool { return shouldChangeSub }
    var result: Observable<ResultType<RequestResponse>> { return resultSubject.asObservable() }
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
    private let resultSubject = PublishSubject<ResultType<RequestResponse>>()
    private let progressSubject = PublishSubject<Bool>()
    private let validationSubject = BehaviorSubject<AppRoundedTextFieldValidation>(value: .neutral)
    private let localizedTextSubject: BehaviorSubject<LocalizedText>

    private let mobileNumberSubject: BehaviorSubject<String?> = BehaviorSubject(value: "+92 ")
    private let rememberMeSubject: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    private let isFirstResponderSubject: BehaviorSubject<Bool> = BehaviorSubject(value: false)

    // properties
    private var countryList = [Country]()
    private var currentItem = 0

    private let disposeBag: DisposeBag = DisposeBag()
    private let credentialsManager: CredentialsStoreType
    private let repositoryProvider: (_ countryCode: String) -> LoginRepositoryType
    private var repository: LoginRepositoryType!

    init(repositoryProvider: @escaping (_ countryCode: String) -> LoginRepositoryType,
         credentialsManager: CredentialsStoreType,
         countryListProvider: CountryListProviderType) {

        self.repositoryProvider = repositoryProvider
        self.credentialsManager = credentialsManager
        self.countryList = countryListProvider.list()

        self.localizedTextSubject = BehaviorSubject(value: (
            heading: "screen_sign_in_display_text_heading_text".localized,
            remember: "screen_sign_in_display_text_remember_id_text".localized,
            signIn: "screen_sign_in_button_sign_in".localized,
            create: "screen_sign_in_display_text_create_account".localized,
            signUp: "screen_sign_in_button_sign_up".localized
        ))

        flagSubject.onNext(countryList.first?.flagIconImageName ?? "")
        // mobileNumberSubject.onNext(countryList.first?.callingCode ?? "+92 ")

        let selectNumber = mobileNumberSubject
            .distinctUntilChanged()
            .debug("HHHH", trimOutput: true)
            .unwrap()
            .map { $0.toFormatedPhone }
            .share()

        selectNumber
            .map { $0.number }
            .subscribe(onNext: { string in
                DispatchQueue.main.async { self.mobileNumberSubject.onNext(string) }
            }).disposed(by: disposeBag)

        Observable.combineLatest(selectNumber, isFirstResponderSubject)
            .map { $0.0.isFormated ? AppRoundedTextFieldValidation.valid: .neutral }
            .bind(to: validationSubject)
            .disposed(by: disposeBag)

        Observable.combineLatest(selectNumber, textWillChangeSubject)
            .do(onNext: {
                let ctext = $0.1.currentText?.replacingOccurrences(of: " ", with: "") ?? ""
                let res1 = $0.1.range.location > self.countryList[self.currentItem].callingCode.count - 1
                let res2 = (ctext.count + $0.1.text.count < 14 || $0.1.text.count == 0)
                let res3 = (!$0.0.isFormated || $0.1.text.count == 0)
                self.shouldChangeSub = res1 && res2 && res3
            }).subscribe().disposed(by: disposeBag)

        self.repository = repositoryProvider("PK")
        verifyUserRequest()

        rememberUsername(credentialsManager)

        guard credentialsManager.isCredentialsAvailable else {
            _ = credentialsManager.clearUsername()
            return
        }
    }

    func isErrorUserBlocked(_ error: Error) -> Bool {
        if case let NetworkError.internalServerError(internalError) = error {
            return internalError?.errors.first?.code == "AD-10018"
        }
        return false
    }
}

private extension LoginViewModel {
    func verifyUserRequest() {
        let verifyUserRequest = signInSubject.withLatestFrom(mobileNumberSubject.asObservable())
            .map({ $0?.toSimplePhoneNumber ?? "" })
            .do(onNext: { [unowned self] _ in self.progressSubject.onNext(true) })
            .flatMapLatest {
                self.repository.verifyUser(username: $0)
            }
            .debug("verifyUser", trimOutput: false)
            .do(onNext: { [unowned self] _ in self.progressSubject.onNext(false) })
            .share()

        verifyUserRequest.elements()
            .filter { $0 == false }
            .map({ _ in AppRoundedTextFieldValidation.invalid("screen_sign_in_display_text_error_text".localized) })
            .bind(to: validationSubject)
            .disposed(by: disposeBag)

        verifyUserRequest.elements().filter { $0 == true }.withLatestFrom(mobileNumberSubject)
            .do(onNext: { [unowned self] userName in
                let user = userName?.toSimplePhoneNumber ?? ""
                self.credentialsManager.secureCredentials(username: user, passcode: "")
            })
            .map { ResultType.success(RequestResponse(userName: $0 ?? "", isBlocked: false)) }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)

        let apiError = verifyUserRequest.errors()

        apiError.filter { [unowned self] error in !self.isErrorUserBlocked(error) }
            .map { AppRoundedTextFieldValidation.invalid($0.localizedDescription) }
            .bind(to: validationSubject)
            .disposed(by: disposeBag)

        apiError.filter { [unowned self] error in self.isErrorUserBlocked(error) }
            .withLatestFrom(mobileNumberSubject)
            .map { ResultType.success(RequestResponse(userName: $0 ?? "", isBlocked: true)) }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)
    }

    func rememberUsername(_ credentialsManager: CredentialsStoreType) {
        rememberMeSubject.onNext(credentialsManager.remembersId ?? true)
        rememberMeSubject
            .do(onNext: { if !$0 { _ = credentialsManager.clearUsername() } })
            .subscribe(onNext: { credentialsManager.setRemembersId($0) })
            .disposed(by: disposeBag)
    }
}
