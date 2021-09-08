//
//  PhoneNumberVerificationViewModel.swift
//  YAP
//
//  Created by Zain on 25/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents


protocol PhoneNumberVerificationViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var viewAppearedObserver: AnyObserver<Bool> { get }
    var sendObserver: AnyObserver<OnboardingStage> { get }
    var stageObserver: AnyObserver<OnboardingStage> { get }
    var resendObserver: AnyObserver<Void> { get }
    var poppedObserver: AnyObserver<Void> { get }
}

protocol PhoneNumberVerificationViewModelOutput {
    var valid: Observable<Bool> { get }
    var phoneNumber: Observable<String> { get }
    var result: Observable<OnBoardingUser> { get }
    var timerText: Observable<String> { get }
    var resendActive: Observable<Bool> { get }
    var showError: Observable<String> { get }
    var showAlert: Observable<String> { get }
    var endEditting: Observable<Bool> { get }
    var progress: Observable<Float> { get }
    var stage: Observable<OnboardingStage> { get }
   // var waiting: Observable<Int> { get }
}

protocol PhoneNumberVerificationViewModelType {
    var inputs: PhoneNumberVerificationViewModelInput { get }
    var outputs: PhoneNumberVerificationViewModelOutput { get }
}

class PhoneNumberVerificationViewModel: PhoneNumberVerificationViewModelInput, PhoneNumberVerificationViewModelOutput, PhoneNumberVerificationViewModelType {
    var inputs: PhoneNumberVerificationViewModelInput { return self }
    var outputs: PhoneNumberVerificationViewModelOutput { return self }
    
    private let textSubject = BehaviorSubject<String?>(value: nil)
    private let viewAppearedSubject = PublishSubject<Bool>()
    private let validSubject = BehaviorSubject<Bool>(value: false)
    private let resultSubject = PublishSubject<OnBoardingUser>()
    private let phoneNumberSubject = BehaviorSubject<String>(value: "")
    private let sendSubject = PublishSubject<OnboardingStage>()
    private let timerTextSubject = BehaviorSubject<String>(value: "00:10")
    private let resendActiveSubject = BehaviorSubject<Bool>(value: false)
    private let showErrorSubject = PublishSubject<String>()
    private let showAlertSubject = PublishSubject<String>()
    private let endEdittingSubject = PublishSubject<Bool>()
    private let progressSubject = PublishSubject<Float>()
    private let stageSubject = PublishSubject<OnboardingStage>()
    private let resendSubject = PublishSubject<Void>()
    private let poppedSubject = PublishSubject<Void>()
    
    // inputs
    var textObserver: AnyObserver<String?> { return textSubject.asObserver() }
    var viewAppearedObserver: AnyObserver<Bool> { return viewAppearedSubject.asObserver() }
    var sendObserver: AnyObserver<OnboardingStage> { return sendSubject.asObserver() }
    var stageObserver: AnyObserver<OnboardingStage> { return stageSubject.asObserver() }
    var resendObserver: AnyObserver<Void> { return resendSubject.asObserver() }
    var poppedObserver: AnyObserver<Void> { return poppedSubject.asObserver() }
    
    // outputs
    var valid: Observable<Bool> { return validSubject.asObservable() }
    var result: Observable<OnBoardingUser> { return resultSubject.asObservable() }
    var phoneNumber: Observable<String> { return phoneNumberSubject.asObservable() }
    var timerText: Observable<String> { return timerTextSubject.asObservable() }
    var resendActive: Observable<Bool> { return resendActiveSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var endEditting: Observable<Bool> { return endEdittingSubject.asObservable() }
    var progress: Observable<Float> { return progressSubject.asObservable() }
    var stage: Observable<OnboardingStage> { return stageSubject.asObservable() }
    var showAlert: Observable<String> { return showAlertSubject.asObservable() }
    
    private let disposeBag = DisposeBag()
    private let phoneNumberText: String
    private var otpCode: String = ""
    private let otpTime: TimeInterval
    private var otpResendTime: TimeInterval
    private var user: OnBoardingUser!
    private var timer: Timer?
    private let resendTimeSubject = BehaviorSubject<TimeInterval>(value: 10)
    private let resendBlocked = BehaviorSubject<Bool>(value: false)
    ///private let repository = OnBoardingRepository()
    private var otpForRequest: String?
    
    init(user: OnBoardingUser, otpTime: TimeInterval = 10) {
        self.user = user
        self.otpTime = otpTime
        self.phoneNumberText = user.mobileNo.formattedValue ?? ""
        self.otpResendTime = otpTime
        
        phoneNumberSubject.onNext( "screen_verify_phone_number_display_text_sub_title".localized + "\n" + phoneNumberText)
        
        textSubject.map { [unowned self] text -> Bool in
            self.otpCode = text ?? ""
            return text?.count ?? 0 == 6
        }.bind(to: validSubject).disposed(by: disposeBag)
        
        let viewAppeared = viewAppearedSubject.filter { $0 }
        
        viewAppeared.map { [unowned self] _ -> Float in return self.user.accountType == .b2cAccount ? 0.4 : 0.428 }.bind(to: progressSubject).disposed(by: disposeBag)
        viewAppeared.map { [unowned self] _ in self.otpCode.count == 6 }.bind(to: validSubject).disposed(by: disposeBag)
        /*
        let request = sendSubject.filter {
            if case OnboardingStage.otp = $0 { return true}
            return false
        }
        .do(onNext: {[unowned self] _ in
            self.endEdittingSubject.onNext(true)
            YAPProgressHud.showProgressHud()
        }).withLatestFrom(textSubject).unwrap().flatMap {[unowned self] text -> Observable<Event<WaitingList>> in
            guard let countryCode = user.mobileNo.countryCode, let number = user.mobileNo.number else { return .error(NetworkErrors.notFound)}
            return self.repository.verifyOTP(countryCode: countryCode, phoneNumber: number, otp: text)
            
        }.do(onNext: { _ in
            YAPProgressHud.hideProgressHud()
        }).share()
        
        // request.elements().filter{ $0.isWaiting }.map{ Int($0.waitingListRank ?? "1") ?? 1 }.bind(to: waitingSubject).disposed(by: disposeBag)
        
        request.elements().map{ $0.otpToken }
            .map { [weak self] in
                self?.user.otpVerificationToken = $0
                AppAnalytics.shared.logEvent(OnBoardingEvent.otpCodeStarted())
                return self?.user }.unwrap()
            .bind(to: resultSubject)
            .disposed(by: disposeBag)
        
        let resendReqeust = resendSubject.do(onNext: { self.endEdittingSubject.onNext(true) }).flatMap { [unowned self] _ -> Observable<Event<String?>> in
            YAPProgressHud.showProgressHud()
            return self.repository.createMobileOTP(countryCode: self.user.mobileNo.countryCode ?? "", phoneNumber: self.user.mobileNo.number ?? "", accountType: user.accountType.rawValue)
        }.do(onNext: {_ in
            YAPProgressHud.hideProgressHud()
        }).share()
        
        resendReqeust.elements().do(onNext: { [unowned self] _ in
            self.startTimer()
            AppAnalytics.shared.logEvent(OnBoardingEvent.resendOtp())
        }).map { _ in  "screen_verify_phone_number_display_text_resend_otp_success".localized }.bind(to: showAlertSubject).disposed(by: disposeBag)
        
        Observable.merge(request.errors(), resendReqeust.errors()).map { $0.localizedDescription }.bind(to: showErrorSubject).disposed(by: disposeBag)
         
        request.errors().map{ error -> Bool in
            guard case let NetworkErrors.internalServerError(serverError) = error else { return false }
            guard serverError?.errors.first?.code == "1095" else { return false }
            return true
        }
        .bind(to: resendBlocked)
        .disposed(by: disposeBag)
        
        request.errors().map{ _ in nil }
            .do(onNext: { [unowned self] in self.otpForRequest = $0 })
            .bind(to: textSubject).disposed(by: disposeBag)
         */
        startTimer()
        
        poppedSubject.subscribe(onNext: { [unowned self] in
            self.completeSubscriptions()
        }).disposed(by: disposeBag)
        /*
        request.elements()
            .map{ _ in OnBoardingEvent.otpCodeEntered() }
            .bind(to: AppAnalytics.shared.rx.logEvent)
            .disposed(by: disposeBag)
        */
        resendTimeSubject.map{ $0.timeString }.bind(to: timerTextSubject).disposed(by: disposeBag)
        
        Observable.combineLatest(resendTimeSubject.map{ $0 == 0}, resendBlocked)
            .map{ $0.0 && !$0.1 }
            .bind(to: resendActiveSubject)
            .disposed(by: disposeBag)
        
        textSubject.unwrap()
            .filter{ [unowned self] in $0.count == 6 && self.otpForRequest != $0 }
            .do(onNext: { [unowned self] in self.otpForRequest = $0 }).map{ _ in .otp }
            .bind(to: sendObserver).disposed(by: disposeBag)
    }
}

private extension PhoneNumberVerificationViewModel {
    
    func completeSubscriptions() {
        resultSubject.onCompleted()
        validSubject.onCompleted()
        stageSubject.onCompleted()
        progressSubject.onCompleted()
        sendSubject.dispose()
    }
    
    func startTimer() {
        resendActiveSubject.onNext(false)
        otpResendTime = otpTime
        timerTextSubject.onNext(otpResendTime.timeString)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            guard let `self` = self else {
                timer.invalidate()
                return
            }
            self.timer = timer
            if self.otpResendTime == 0 {
                timer.invalidate()
                self.otpResendTime = self.otpTime
                return
            }
            self.otpResendTime -= 1
            self.resendTimeSubject.onNext(self.otpResendTime)
        }
    }
}

fileprivate extension TimeInterval {
    
    var timeString: String {
        let minutes = Int(self/60.0)
        let seconds = Int(self) % 60
        
        return String.init(format: "%02d:%02d", minutes, seconds)
    }
}
