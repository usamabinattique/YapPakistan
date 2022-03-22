//
// VerifyMobileOTPViewModel.swift
// YAPKit
//
// Created by Hussaan S on 28/06/2019.
// Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import YAPComponents

typealias OTPVerificationResultType = (token: String?, phoneNumber: String?, session: Session?)

enum OTPAction: String, Codable {
    case topupSubCard = "TOP_UP_SUPPLEMENTARY"
    case withdrawFromSubCard = "WITHDRAWAL_SUPPLEMENTARY"
    case forgotPassword = "FORGOT_PASSWORD"
    case forgotPIN = "FORGOT_CARD_PIN"
    case reissueCard = "CARD_REISSUE"
    case topup = "TOPUP"
    case changeMobileNumber = "CHANGE_MOBILE_NO"
    case changeEmail = "CHANGE_EMAIL"
    case y2y = "Y2Y"
    case domesticTransfer = "DOMESTIC_TRANSFER"
    case uaefts = "UAEFTS"
    case rmt = "RMT"
    case swift = "SWIFT"
    case cashPayout = "CASHPAYOUT"
    case deviceVerification = "DEVICE_VERIFICATION"
    case domesticBeneficiary = "DOMESTIC_BENEFICIARY"
    case rmtBeneficiary = "RMT_BENEFICIARY"
    case nonRmtBeneficiary = "SWIFT_BENEFICIARY"
    case cashPickupBeneficiary = "CASHPAYOUT_BENEFICIARY"
    case ibft = "IBFT_BENEFICIARY"

}

protocol VerifyMobileOTPViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var textObserver: AnyObserver<String?> { get }
    var viewAppearedObserver: AnyObserver<Bool> { get }
    var sendObserver: AnyObserver<Void> { get }
    var resendOTPObserver: AnyObserver<Void> { get }
    var generateOTPObserver: AnyObserver<Void> { get }
}

protocol VerifyMobileOTPViewModelOutput {
    var back: Observable<Void> { get }
    var valid: Observable<Bool> { get }
    var heading: Observable<String?> { get }
    var subheading: Observable<String?> { get }
    var badge: Observable<UIImage?> { get }
    var image: Observable<UIImage?> { get }
    var generateOTP: Observable<Void> { get }
    var otp: Observable<String?> { get }
    var result: Observable<OTPVerificationResultType> { get }
    var loginResult: Observable<LoginOTPVerificationResult> { get }
    var timerText: Observable<String> { get }
    var resendActive: Observable<Bool> { get }
    var generateOTPError: Observable<String> { get }
    var error: Observable<String> { get }
    var editing: Observable<Bool> { get }
    var imageFlag: Observable<Bool> { get }
    var OTPResult: Observable<String> { get }
    var mobileNo: Observable<String?> { get }
    var showAlert: Observable<String> { get }
    var backImage: Observable<BackButtonType> { get }
    
    var addBankBeneficiaryResult: Observable<AddBankBeneficiaryResponse> { get }
}

protocol VerifyMobileOTPViewModelType {
    typealias OnLoginClosure = (Session,
                                inout AccountProvider?,
                                inout DemographicsRepositoryType?) -> Void

    var inputs: VerifyMobileOTPViewModelInput { get }
    var outputs: VerifyMobileOTPViewModelOutput { get }
}

open class VerifyMobileOTPViewModel: VerifyMobileOTPViewModelInput,
                                     VerifyMobileOTPViewModelOutput,
                                     VerifyMobileOTPViewModelType {
    var inputs: VerifyMobileOTPViewModelInput { return self }
    var outputs: VerifyMobileOTPViewModelOutput { return self }

    let textSubject = BehaviorSubject<String?>(value: nil)
    let viewAppearedSubject = PublishSubject<Bool>()
    let loginResultSubject = PublishSubject<LoginOTPVerificationResult>()
    let sendSubject = PublishSubject<Void>()
    let generateOTPSubject = PublishSubject<Void>()
    let otpActionSubject: BehaviorSubject<OTPAction?>
    let generateOTPErrorSubject = PublishSubject<String>()
    let errorSuject = PublishSubject<String>()
    let editingSubject = PublishSubject<Bool>()
    let OTPResultSubject = PublishSubject<String>()
    let showAlertSubject = PublishSubject<String>()

    private let resultSubject = PublishSubject<OTPVerificationResultType>()
    private let backSubject = PublishSubject<Void>()
    private let validSubject = BehaviorSubject<Bool>(value: false)
    private let timerTextSubject = BehaviorSubject<String>(value: "00: 10")
    private let timerSubject: BehaviorSubject<TimeInterval>
    private let resendTimeSubject: BehaviorSubject<TimeInterval>
    private let resendTriesSubject: BehaviorSubject<Int>
    private let resendActiveSubject = BehaviorSubject<Bool>(value: false)
    private let headingSubject: BehaviorSubject<String?>
    private let subheadingSubject: BehaviorSubject<String?>
    private let badgeSubject: Observable<UIImage?>
    private let imageSubject: Observable<UIImage?>
    private let otpSubject: BehaviorSubject<String?>
    private let otpLengthSubject: BehaviorSubject<Int>
    private let resendOTPSubject = PublishSubject<Void>()
    private let imageFlagSubject: BehaviorSubject<Bool>
    private let mobileNoSubject = BehaviorSubject<String?>(value: nil)
    private let backImageSubject = BehaviorSubject<BackButtonType>(value: .backEmpty)
    private let addBankBeneficiaryResultSubject = ReplaySubject<AddBankBeneficiaryResponse>.create(bufferSize: 1)

    // inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var textObserver: AnyObserver<String?> { textSubject.asObserver() }
    var viewAppearedObserver: AnyObserver<Bool> { viewAppearedSubject.asObserver() }
    var sendObserver: AnyObserver<Void> { sendSubject.asObserver() }
    var resendOTPObserver: AnyObserver<Void> { resendOTPSubject.asObserver() }
    var generateOTPObserver: AnyObserver<Void> { generateOTPSubject.asObserver() }

    // outputs
    var back: Observable<Void> { backSubject.asObservable() }
    var valid: Observable<Bool> { validSubject.asObservable() }
    var heading: Observable<String?> { headingSubject.asObservable() }
    var subheading: Observable<String?> { subheadingSubject.asObservable() }
    var badge: Observable<UIImage?> { badgeSubject.asObservable() }
    var image: Observable<UIImage?> { imageSubject.asObservable() }
    var generateOTP: Observable<Void> { generateOTPSubject.asObservable() }
    var otp: Observable<String?> { otpSubject.asObservable() }
    var result: Observable<OTPVerificationResultType> { resultSubject.asObservable() }
    var loginResult: Observable<LoginOTPVerificationResult> { loginResultSubject.asObservable() }
    var timerText: Observable<String> { timerTextSubject.asObservable() }
    var resendActive: Observable<Bool> { resendActiveSubject.asObservable() }
    var generateOTPError: Observable<String> { generateOTPErrorSubject.asObservable() }
    var error: Observable<String> { errorSuject.asObservable() }
    var editing: Observable<Bool> { editingSubject.asObservable() }
    var imageFlag: Observable<Bool> { imageFlagSubject.asObservable() }
    var OTPResult: Observable<String> { OTPResultSubject.asObservable() }
    var mobileNo: Observable<String?> { mobileNoSubject.asObservable() }
    var showAlert: Observable<String> { showAlertSubject.asObservable() }
    var backImage: Observable<BackButtonType> { backImageSubject.asObservable() }
    
    var addBankBeneficiaryResult: Observable<AddBankBeneficiaryResponse> { addBankBeneficiaryResultSubject.asObservable() }

    let disposeBag = DisposeBag()
    let repository: OTPRepositoryType
    let otpBlocked = BehaviorSubject<Bool>(value: false)
    var otpForRequest: String?

    init(action: OTPAction,
         heading: String? = nil,
         subheading: String,
         image: UIImage? = nil,
         badge: UIImage? = nil,
         otpTime: TimeInterval = 60,
         otpLength: Int = 6,
         resendTries: Int = 4,
         repository: OTPRepositoryType,
         mobileNo: String = "",
         passcode: String,
         backButtonImage: BackButtonType = .backEmpty, addBankBeneficiaryInput: AddBankBeneficiaryRequest? = nil) {
        self.headingSubject = BehaviorSubject(value: heading)
        self.subheadingSubject = BehaviorSubject(value: subheading)
        self.badgeSubject = BehaviorSubject(value: badge)
        self.imageSubject = BehaviorSubject(value: image)
        self.otpSubject = BehaviorSubject(value: nil)
        self.otpLengthSubject = BehaviorSubject(value: otpLength)
        self.resendTimeSubject = BehaviorSubject(value: otpTime)
        self.resendTriesSubject = BehaviorSubject(value: resendTries)
        self.timerSubject = BehaviorSubject(value: otpTime)
        self.repository = repository
        self.otpActionSubject = BehaviorSubject(value: action)
        self.imageFlagSubject = BehaviorSubject(value: image != nil)
        self.backImageSubject.onNext(backButtonImage)

        Observable.combineLatest(textSubject, otpLengthSubject)
            .map { $0.0?.count ?? 0 == $0.1 }.bind(to: validSubject)
            .disposed(by: disposeBag)
//        generateOneTimePasscode(mobileNo: mobileNo)
//        verifyOneTimePasscode(mobileNo: mobileNo, passcode: passcode)
        if action != .ibft {
            generateOneTimePasscode(mobileNo: mobileNo)
            verifyOneTimePasscode(mobileNo: mobileNo, passcode: passcode)
        } else {
            generateOtpForIBFT(action: .ibft)
            if let input = addBankBeneficiaryInput {
                verifyOtpForIBFT(input: input)
            }
        }
       

        Observable.combineLatest(otpBlocked, timerSubject.map{ $0 <= 0 })
            .map{ !$0.0 && $0.1 }
            .bind(to: resendActiveSubject)
            .disposed(by: disposeBag)

        timerSubject.filter { $0 >= 0 }
            .map(timeString)
            .bind(to: timerTextSubject)
            .disposed(by: disposeBag)

        resendOTPSubject.withLatestFrom(resendTimeSubject)
            .bind(to: timerSubject)
            .disposed(by: disposeBag)

        textSubject.unwrap()
            .filter{ [unowned self] in $0.count == otpLength && self.otpForRequest != $0 }
            .do(onNext: { [unowned self] in self.otpForRequest = $0 }).map{ _ in }
            .bind(to: sendObserver)
            .disposed(by: disposeBag)
    }

    open func generateOneTimePasscode(mobileNo: String) {
        let generateOTPRequest = generateOTPSubject
            .do(onNext: { YAPProgressHud.showProgressHud() })
            .withLatestFrom(otpActionSubject).flatMap { [unowned self] otpAction -> Observable<Event<String?>> in
                return self.repository.generateOTP(action: otpAction!, mobileNumber: mobileNo)
            }
            .do(onNext: { _ in
                    YAPProgressHud.hideProgressHud() })
            .share()

        generateOTPRequest.errors().map {
            $0.localizedDescription

        }.bind(to: generateOTPErrorSubject).disposed(by: disposeBag)

        var timerDisposable: Disposable?

        generateOTPRequest.elements().do(onNext: { _ in
            timerDisposable?.dispose()
            timerDisposable = self.startTimer()
        }).map { _ in true }.bind(to: editingSubject).disposed(by: disposeBag)

        generateOTPRequest.elements()
            .skip(1)
            .map { _ in "screen_otp_genration_success".localized }
            .bind(to: showAlertSubject)
            .disposed(by: disposeBag)
    }

    open func verifyOneTimePasscode(mobileNo: String, passcode: String) {
        let verifyRequest = sendSubject
            .withLatestFrom(Observable.combineLatest(textSubject.unwrap(), otpActionSubject))
            .do(onNext: { [unowned self] _ in
                self.editingSubject.onNext(false)
                YAPProgressHud.showProgressHud()
            })
            .flatMap { [unowned self] _ -> Observable<Event<String?>> in
                return self.repository
                    .generateLoginOTP(username: mobileNo, passcode: passcode, deviceId: UIDevice.deviceId)
            }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()

        let isOtpBlocked = verifyRequest.errors().map{ error -> Bool in
            guard case let NetworkErrors.internalServerError(serverError) = error else { return false }
            guard serverError?.errors.first?.code == "1095" else { return false }
            return true
        }

        isOtpBlocked.bind(to: otpBlocked).disposed(by: disposeBag)

        Observable.merge(isOtpBlocked.filter{ !$0 }.map{ _ in })
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .withLatestFrom(verifyRequest.errors()).map{ $0.localizedDescription }
            .bind(to: errorSuject)
            .disposed(by: disposeBag)

        verifyRequest.errors().map { _ in nil }
            .do(onNext: { [unowned self] in self.otpForRequest = $0 })
            .bind(to: textSubject).disposed(by: disposeBag)
        verifyRequest.elements().map{ $0?.components(separatedBy: "%") }
            .do(onNext: { components in
                if let jwt = components?.count ?? 0 > 1 ? components?.last : nil {
                    #warning("Need to set jwt")
                }
            })
            .map{ (token: $0?.first, phoneNumber: nil, session: nil) }
            .bind(to: resultSubject).disposed(by: disposeBag)
    }
    
    
    func generateOtpForIBFT(action: OTPAction) {
        
        let generateOTPRequest = generateOTPSubject
            .do(onNext: { YAPProgressHud.showProgressHud() })
            .withLatestFrom(otpActionSubject).flatMap { [unowned self] otpAction -> Observable<Event<String?>> in
                return self.repository.generate(action: otpAction!.rawValue)
            }
            .do(onNext: { _ in
                    YAPProgressHud.hideProgressHud() })
            .share()

        generateOTPRequest.errors().map {
            $0.localizedDescription

        }.bind(to: generateOTPErrorSubject).disposed(by: disposeBag)

        var timerDisposable: Disposable?

        generateOTPRequest.elements().do(onNext: { _ in
            timerDisposable?.dispose()
            timerDisposable = self.startTimer()
        }).map { _ in true }.bind(to: editingSubject).disposed(by: disposeBag)

        generateOTPRequest.elements()
            .map { _ in "screen_otp_genration_success".localized }
            .bind(to: showAlertSubject)
            .disposed(by: disposeBag)
    }
    
    func verifyOtpForIBFT(input: AddBankBeneficiaryRequest) {
        let verifyRequest = sendSubject
            .withLatestFrom(Observable.combineLatest(textSubject.unwrap(), otpActionSubject))
            .do(onNext: { [unowned self] _ in
                self.editingSubject.onNext(false)
                YAPProgressHud.showProgressHud()
            })
            .flatMap { [unowned self] (otp,action) -> Observable<Event<String?>> in
                return self.repository.verifyOTP(action: action?.rawValue ?? OTPAction.ibft.rawValue, otp: otp)
                   
            }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()

        let isOtpBlocked = verifyRequest.errors().map{ error -> Bool in
            guard case let NetworkErrors.internalServerError(serverError) = error else { return false }
            guard serverError?.errors.first?.code == "1095" else { return false }
            return true
        }

        isOtpBlocked.bind(to: otpBlocked).disposed(by: disposeBag)

        Observable.merge(isOtpBlocked.filter{ !$0 }.map{ _ in })
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .withLatestFrom(verifyRequest.errors()).map{ $0.localizedDescription }
            .bind(to: errorSuject)
            .disposed(by: disposeBag)

        verifyRequest.errors().map { _ in nil }
            .do(onNext: { [unowned self] in self.otpForRequest = $0 })
            .bind(to: textSubject).disposed(by: disposeBag)
        let addBeneficiaryRequest = verifyRequest.elements()
            .flatMap { [unowned self] _ -> Observable<Event<AddBankBeneficiaryResponse>> in
                YAPProgressHud.showProgressHud()
                return repository.addBankBenefiiary(input: input)
                // .generateLoginOTP(username: mobileNo, passcode: passcode, deviceId: UIDevice.deviceId)
            }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()
                
                
                addBeneficiaryRequest.errors().map{ $0.localizedDescription }
                .bind(to: errorSuject)
                .disposed(by: disposeBag)
           
        addBeneficiaryRequest.elements()
            .bind(to: addBankBeneficiaryResultSubject).disposed(by: disposeBag)
    }
}

public extension VerifyMobileOTPViewModel {

    func startTimer() -> Disposable {
        let timer = Observable<NSInteger>.timer(RxTimeInterval.milliseconds(0),
                                                period: RxTimeInterval.seconds(1),
                                                scheduler: MainScheduler.instance)
        return Observable.combineLatest(timer, resendTimeSubject)
            .map { $0.1 - TimeInterval($0.0) }
            .bind(to: timerSubject)
    }
}

// TODO: globalize extension to TimeInterval
fileprivate extension VerifyMobileOTPViewModel {
    func timeString(timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60.0)
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d: %02d", minutes, seconds)
    }
}
