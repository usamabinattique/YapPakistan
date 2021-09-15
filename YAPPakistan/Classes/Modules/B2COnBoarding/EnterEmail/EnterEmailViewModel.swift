//
//  EnterEmailViewModel.swift
//  YAP
//
//  Created by Zain on 29/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol EnterEmailViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var sendObserver: AnyObserver<OnboardingStage> { get }
    var keyboardNextObserver: AnyObserver<Void> { get }
    var registerDeviceObserver: AnyObserver<OnBoardingUser> { get }
    var viewAppearedObserver: AnyObserver<Bool> { get }
    var demographicsSuccessObserver: AnyObserver<Void> { get }
    var stageObserver: AnyObserver<OnboardingStage> { get }
    var poppedObserver: AnyObserver<Void> { get }
}

protocol EnterEmailViewModelOutput {
    var emailValidation: Observable<AppRoundedTextFieldValidation> { get }
    var valid: Observable<Bool> { get }
    var result: Observable<(user: OnBoardingUser, session: Session)> { get }
    var error: Observable<String?> { get }
    var subHeadingHidden: Observable<Bool> { get }
    var heading: Observable<String> { get }
    var showError: Observable<String> { get }
    var endEditting: Observable<Bool> { get }
    var deviceRegistration: Observable<OnBoardingUser> { get }
    var progress: Observable<Float> { get }
    var stage: Observable<OnboardingStage> { get }
    var demographicsSuccess: Observable<Void> { get }
    var verificationText: Observable<String> { get }
}

protocol EnterEmailViewModelType {
    typealias OnAuthenticateClosure = (Session, inout OnBoardingRepository?, inout AccountProvider?) -> Void

    var inputs: EnterEmailViewModelInput { get }
    var outputs: EnterEmailViewModelOutput { get }
}

class EnterEmailViewModel: EnterEmailViewModelInput, EnterEmailViewModelOutput, EnterEmailViewModelType {
    var inputs: EnterEmailViewModelInput { return self }
    var outputs: EnterEmailViewModelOutput { return self }
    
    private let textSubject = PublishSubject<String?>()
    private let sendSubject = PublishSubject<OnboardingStage>()
    private let keyboardNextSubject = PublishSubject<Void>()
    private let viewAppearedSubject = BehaviorSubject<Bool>(value: false)
    private let deviceRegistrationSubject = PublishSubject<OnBoardingUser>()
    private let demographicsSuccessSubject = PublishSubject<Void>()
    
    private let emailValidationSubject = BehaviorSubject<AppRoundedTextFieldValidation>(value: .neutral)
    private let validSubject = BehaviorSubject<Bool>(value: false)
    private let resultSubject = PublishSubject<(user: OnBoardingUser, session: Session)>()
    private let errorSubject = BehaviorSubject<String?>(value: nil)
    private let subHeadingHiddenSubject = BehaviorSubject<Bool>(value: true)
    private let headingSubject = BehaviorSubject<String>(value: "")
    private let showErrorSubject = PublishSubject<String>()
    private let endEdittingSubject = PublishSubject<Bool>()
    private let progressSubject = PublishSubject<Float>()
    private let stageSubject = PublishSubject<OnboardingStage>()
    private let verificationTextSubject = BehaviorSubject<String>(value: "")
    private let emailVerifiedSubject = PublishSubject<Void>()
    private let poppedSubject = PublishSubject<Void>()
    
    // inputs
    var textObserver: AnyObserver<String?> { return textSubject.asObserver() }
    var sendObserver: AnyObserver<OnboardingStage> { return sendSubject.asObserver() }
    var keyboardNextObserver: AnyObserver<Void> { return keyboardNextSubject.asObserver() }
    var registerDeviceObserver: AnyObserver<OnBoardingUser> { return deviceRegistrationSubject.asObserver() }
    var viewAppearedObserver: AnyObserver<Bool> { return viewAppearedSubject.asObserver() }
    var stageObserver: AnyObserver<OnboardingStage> { return stageSubject.asObserver() }
    var demographicsSuccessObserver: AnyObserver<Void> { return demographicsSuccessSubject.asObserver() }
    var poppedObserver: AnyObserver<Void> { return poppedSubject.asObserver() }
    
    // outputs
    var emailValidation: Observable<AppRoundedTextFieldValidation> { return emailValidationSubject.asObservable() }
    var valid: Observable<Bool> { return validSubject.asObservable() }
    var result: Observable<(user: OnBoardingUser, session: Session)> { return resultSubject.asObservable() }
    var error: Observable<String?> { return errorSubject.asObservable() }
    var subHeadingHidden: Observable<Bool> { return subHeadingHiddenSubject.asObservable() }
    var heading: Observable<String> { return headingSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var endEditting: Observable<Bool> { return endEdittingSubject.asObservable() }
    var deviceRegistration: Observable<OnBoardingUser> { return deviceRegistrationSubject.asObservable() }
    var progress: Observable<Float> { return progressSubject.asObservable() }
    var stage: Observable<OnboardingStage> { return stageSubject.asObservable() }
    var demographicsSuccess: Observable<Void> { return demographicsSuccessSubject.asObservable() }
    var verificationText: Observable<String> { return verificationTextSubject.asObservable() }
    
    private var user: OnBoardingUser
    private var session:Session!
    private let disposeBag = DisposeBag()
    private var isValidInput = false
    private var isEmailSend = false
    private var repository: OnBoardingRepository!

    private let sessionProvider: SessionProviderType
    private let credentialsStore: CredentialsStoreType
    private var accountProvider: AccountProvider?

    init(credentialsStore: CredentialsStoreType,
         referralManager: AppReferralManager,
         sessionProvider: SessionProviderType,
         onBoardingRepository: OnBoardingRepository,
         user: OnBoardingUser,
         onAuthenticate: @escaping OnAuthenticateClosure) {
        self.credentialsStore = credentialsStore
        self.sessionProvider = sessionProvider
        self.repository = onBoardingRepository
        self.user = user
        
        let appeared = viewAppearedSubject.filter { $0 }
        appeared.map { [unowned self] _ in self.isValidInput }.bind(to: validSubject).disposed(by: disposeBag)
        appeared.map { [unowned self] _ in self.user.accountType == .b2cAccount ? 0.8 : 0.142 }.bind(to: progressSubject).disposed(by: disposeBag)
        
        let textValid = textSubject.do(onNext: { [unowned self] in
            self.user.email = $0
            self.isValidInput = ValidationService.shared.validateEmail($0)
        }).map { [unowned self] _ in self.isValidInput }
        
        textValid.bind(to: validSubject).disposed(by: disposeBag)
        textValid.map { $0 ? .valid : .neutral }.bind(to: emailValidationSubject).disposed(by: disposeBag)

        let request = sendSubject
            .filter { [weak self] in
                if let self = self, self.isEmailSend == true {
                    self.resultSubject.onNext((self.user, self.session))
                    self.resultSubject.onCompleted()
                    return false
                } else {
                    if case OnboardingStage.email = $0 { return true }
                    return false
                }
            }
            .do(onNext: {[unowned self] _ in
                self.endEdittingSubject.onNext(true)
                self.emailValidationSubject.onNext(.valid)

                YAPProgressHud.showProgressHud()
            })
            .withLatestFrom(validSubject)
            .filter { $0 }
            .flatMap { [unowned self] _ -> Observable<Event<String?>> in
                return self.repository.signUpEmail(email: self.user.email ?? "",
                                                   accountType: self.user.accountType.rawValue,
                                                   otpToken: self.user.otpVerificationToken ?? "")
            }
            .share()
        
        request.errors()
            .do(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            })
            .map { $0.localizedDescription }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)

        let user = request.elements()
            .map { [weak self] token -> OnBoardingUser? in
                self?.user.otpVerificationToken = token
                self?.user.isWaiting = true

                return self?.user
            }
            .unwrap()
            .share()

        let b2cUser = user.filter { $0.accountType == .b2cAccount }
        b2cUser.map { _ in }.bind(to: demographicsSuccessSubject).disposed(by: disposeBag)

        let saveProfileRequest = b2cUser.flatMap { [unowned self] user -> Observable<Event<String>> in
            self.repository.saveProfile(countryCode: user.mobileNo.countryCode ?? "",
                                        mobileNo: user.mobileNo.number ?? "",
                                        passcode: user.passcode ?? "",
                                        firstName: user.firstName ?? "",
                                        lastName: user.lastName ?? "",
                                        email: user.email ?? "",
                                        token: user.otpVerificationToken ?? "",
                                        whiteListed: false,
                                        accountType: user.accountType.rawValue)
        }.share()

        saveProfileRequest.elements()
            .do(onNext: { [weak self] jwt in
                guard let self = self,
                      let passcode = self.user.passcode,
                      let phoneNumber = self.user.mobileNo.serverFormattedValue else {
                    return
                }

                self.session = self.sessionProvider.makeUserSession(jwt: jwt)
                self.credentialsStore.secureCredentials(username: phoneNumber, passcode: passcode)
                self.isEmailSend = true

                onAuthenticate(self.session, &self.repository, &self.accountProvider)

                self.refreshAccount()
            })
            .filter { _ in referralManager.isReferralInformationAvailable }
            .flatMap { _ in
                self.repository.saveReferralInvitation(inviterCustomerId: referralManager.inviterId ?? "", referralDate: referralManager.invitationTimeString ?? "")
            }
            .elements()
            .do(onNext: { _ in referralManager.removeReferralInformation() })
            .subscribe()
            .disposed(by: disposeBag)

        saveProfileRequest.errors()
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .map { $0.localizedDescription }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)

        /*
        saveProfileRequest.elements()
            .do(onNext: { token in
                AuthenticationManager.shared.setJWT(token)
                let refreshAccount = SessionManager.current.refreshAccount().share()
                let refreshCards = SessionManager.current.refreshCards().share()
                
                Observable.zip(refreshAccount, refreshCards)
                    .subscribe {  _ in
                        YAPProgressHud.hideProgressHud()
                    }.disposed(by: self.disposeBag)

                guard let passcode = self.user.passcode, let phoneNumber = self.user.mobileNo.serverFormattedValue else { return }
                CredentialsManager().secureCredentials(username: phoneNumber, passcode: passcode)
            })
            .filter{ _ in AppReferralManager.isReferralInformationAvailable }
            .flatMap { [unowned self] _ in
                self.repository.saveReferralInformation(inviterId: AppReferralManager.inviterId ?? "", time: AppReferralManager.invitationTimeString ?? "") }
            .elements()
            .do(onNext: { _ in AppReferralManager.removeReferralInformation() })
            .subscribe()
            .disposed(by: disposeBag)

        SessionManager.current.currentAccount
            .unwrap()
            .do(onNext: { [weak self] in
                self?.user.iban = $0.iban
                self?.user.isWaiting = $0.isWaiting
            })
            .map { [weak self] _ in self?.user }
            .unwrap()
            .bind(to: deviceRegistrationSubject)
            .disposed(by: disposeBag)
        */

        keyboardNextSubject.withLatestFrom(validSubject).filter { $0 }.map {_ in OnboardingStage.email }.bind(to: sendSubject).disposed(by: disposeBag)
        
        subHeadingHiddenSubject.onNext(self.user.accountType == .b2cAccount)
        
        let sharedDemographics = demographicsSuccessSubject.share().do(onNext: { _ in
            YAPProgressHud.hideProgressHud()
        })
        
        sharedDemographics.map { .emailVerify }.bind(to: stageSubject).disposed(by: disposeBag)
        sharedDemographics.map { [unowned self] _ in self.user.accountType == .b2cAccount ? self.b2cCofirmationText : self.b2bConfirmationText }.bind(to: verificationTextSubject).disposed(by: disposeBag)
        sharedDemographics.map { _ in  "screen_email_verification_display_text_title".localized }.bind(to: headingSubject).disposed(by: disposeBag)
        sharedDemographics.map { [unowned self] _ in self.user.accountType == .b2cAccount ? 1.0 : 0.285}.bind(to: progressSubject).disposed(by: disposeBag)
        
        headingSubject.onNext(self.user.accountType == .b2cAccount ?  "screen_enter_email_b2c_display_text_title".localized :  "screen_enter_email_b2b_display_text_title".localized)
        
        poppedSubject.subscribe(onNext: { [unowned self] in
            self.resultSubject.onCompleted()
            self.validSubject.onCompleted()
            self.stageSubject.onCompleted()
            self.progressSubject.onCompleted()
            self.deviceRegistrationSubject.onCompleted()
            self.sendSubject.dispose()
        }).disposed(by: disposeBag)

        /* resultSubject.withLatestFrom(textSubject)
            .map { (email) -> AppEvent in
                AppAnalytics.shared.logEvent(OnBoardingEvent.signupEmail())
                return OnBoardingEvent.emailEntered(["email" : email ?? ""])
        }.bind(to: AppAnalytics.shared.rx.logEvent).disposed(by: disposeBag)
        */
    }

    private func refreshAccount() {
        guard let accountProvider = accountProvider else {
            return assertionFailure()
        }

        accountProvider.refreshAccount()
        accountProvider.currentAccount
            .unwrap()
            .do(onNext: { [weak self] in
                YAPProgressHud.hideProgressHud()

                self?.user.iban = $0.iban
                self?.user.isWaiting = $0.isWaiting
            })
            .map { [weak self] _ in self?.user }
            .unwrap()
            .bind(to: deviceRegistrationSubject)
            .disposed(by: disposeBag)
    }
}

private extension EnterEmailViewModel {
    var b2cCofirmationText: String {
        return String(format: "%@, %@ %@\n\n%@", user.firstName ?? "",  "screen_email_verification_b2c_display_text_email_sent".localized, user.email ?? "",  "screen_email_verification_b2c_display_text_email_confirmation".localized)
    }
    
    var b2bConfirmationText: String {
        return String(format: "%@ %@. %@",  "screen_email_verification_b2b_display_text_email_sent".localized, user.email ?? "",  "screen_email_verification_b2b_display_text_email_confirmation".localized)
    }
}
