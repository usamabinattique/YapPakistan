//
//  VerifyMobileOTPViewModel.swift
//  YAPKit
//
//  Created by Hussaan S on 28/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import YAPComponents

public typealias OTPVerificationResultType = (token: String?, phoneNumber: String?, session: Session?)

public enum OTPAction: String, Codable {
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
    
}

public protocol VerifyMobileOTPViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var textObserver: AnyObserver<String?> { get }
    var viewAppearedObserver: AnyObserver<Bool> { get }
    var sendObserver: AnyObserver<Void> { get }
    var resendOTPObserver: AnyObserver<Void> { get }
    var generateOTPObserver: AnyObserver<Void> { get }
}

public protocol VerifyMobileOTPViewModelOutput {
    var back: Observable<Void> { get }
    var valid: Observable<Bool> { get }
    var heading: Observable<NSAttributedString?> { get }
    var subheading: Observable<NSAttributedString?> { get }
    var badge: Observable<UIImage?> { get }
    var image: Observable<UIImage?> { get }
    var generateOTP: Observable<Void> { get }
    var otp: Observable<String?> { get }
    var result: Observable<OTPVerificationResultType> { get }
    var loginResult: Observable<LoginOPTVerificationResult> { get }
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
}

public protocol VerifyMobileOTPViewModelType {
    typealias OnLoginClosure = (Session, inout AccountProvider?) -> Void

    var inputs: VerifyMobileOTPViewModelInput { get }
    var outputs: VerifyMobileOTPViewModelOutput { get }
}

open class VerifyMobileOTPViewModel: VerifyMobileOTPViewModelInput, VerifyMobileOTPViewModelOutput, VerifyMobileOTPViewModelType {
    public var inputs: VerifyMobileOTPViewModelInput { return self }
    public var outputs: VerifyMobileOTPViewModelOutput { return self }
    
    private let backSubject = PublishSubject<Void>()
    public let textSubject = BehaviorSubject<String?>(value: nil)
    public let viewAppearedSubject = PublishSubject<Bool>()
    private let validSubject = BehaviorSubject<Bool>(value: false)
    public let resultSubject = PublishSubject<OTPVerificationResultType>()
    public let loginResultSubject = PublishSubject<LoginOPTVerificationResult>()
    public let sendSubject = PublishSubject<Void>()
    private let timerTextSubject = BehaviorSubject<String>(value: "00:10")
    private let timerSubject: BehaviorSubject<TimeInterval>
    private let resendTimeSubject: BehaviorSubject<TimeInterval>
    private let resendTriesSubject: BehaviorSubject<Int>
    private let resendActiveSubject = BehaviorSubject<Bool>(value: false)
    private let headingSubject: BehaviorSubject<NSAttributedString?>
    private let subheadingSubject: BehaviorSubject<NSAttributedString?>
    private let badgeSubject: Observable<UIImage?>
    private let imageSubject: Observable<UIImage?>
    private let otpSubject: BehaviorSubject<String?>
    private let otpLengthSubject: BehaviorSubject<Int>
    private let resendOTPSubject = PublishSubject<Void>()
    public let generateOTPSubject = PublishSubject<Void>()
    public let otpActionSubject: BehaviorSubject<OTPAction?>
    public let generateOTPErrorSubject = PublishSubject<String>()
    public let errorSuject = PublishSubject<String>()
    public let editingSubject = PublishSubject<Bool>()
    private let imageFlagSubject: BehaviorSubject<Bool>
    private let OTPResultSubject = PublishSubject<String>()
    private let mobileNoSubject = BehaviorSubject<String?>(value: nil)
    public let showAlertSubject = PublishSubject<String>()
    private let backImageSubject = BehaviorSubject<BackButtonType>(value: .backEmpty)
    
    // inputs
    public var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    public var textObserver: AnyObserver<String?> { return textSubject.asObserver() }
    public var viewAppearedObserver: AnyObserver<Bool> { return viewAppearedSubject.asObserver() }
    public var sendObserver: AnyObserver<Void> { return sendSubject.asObserver() }
    public var resendOTPObserver: AnyObserver<Void> { return resendOTPSubject.asObserver() }
    public var generateOTPObserver: AnyObserver<Void> { return generateOTPSubject.asObserver() }
    
    // outputs
    public var back: Observable<Void> { return backSubject.asObservable() }
    public var valid: Observable<Bool> { return validSubject.asObservable() }
    public var heading: Observable<NSAttributedString?> { return headingSubject.asObservable() }
    public var subheading: Observable<NSAttributedString?> { return subheadingSubject.asObservable() }
    public var badge: Observable<UIImage?> { return badgeSubject.asObservable() }
    public var image: Observable<UIImage?> { return imageSubject.asObservable() }
    public var generateOTP: Observable<Void> { return generateOTPSubject.asObservable() }
    public var otp: Observable<String?> { return otpSubject.asObservable() }
    public var result: Observable<OTPVerificationResultType> { return resultSubject.asObservable() }
    public var loginResult: Observable<LoginOPTVerificationResult> { return loginResultSubject.asObservable() }
    public var timerText: Observable<String> { return timerTextSubject.asObservable() }
    public var resendActive: Observable<Bool> { return resendActiveSubject.asObservable() }
    public var generateOTPError: Observable<String> { return generateOTPErrorSubject.asObservable() }
    public var error: Observable<String> { return errorSuject.asObservable() }
    public var editing: Observable<Bool> { return editingSubject.asObservable() }
    public var imageFlag: Observable<Bool> { return imageFlagSubject.asObservable() }
    public var OTPResult: Observable<String> { return OTPResultSubject.asObservable() }
    public var mobileNo: Observable<String?> { return mobileNoSubject.asObservable() }
    public var showAlert: Observable<String> { return showAlertSubject.asObservable() }
    public var backImage: Observable<BackButtonType> { return backImageSubject.asObservable() }
    
    public let disposeBag = DisposeBag()
    private var viewAvailable = false
    public let repository: OTPRepositoryType
    public let otpBlocked = BehaviorSubject<Bool>(value: false)
    public var otpForRequest: String?
    
    public init(action: OTPAction,
                heading: NSAttributedString? = nil,
                subheading: NSAttributedString,
                image: UIImage? = nil,
                badge: UIImage? = nil,
                otpTime: TimeInterval = 10,
                otpLength: Int = 6,
                resendTries: Int = 4,
                repository: OTPRepositoryType,
                mobileNo: String = "",
                backButtonImage: BackButtonType = .backEmpty) {
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
        
        Observable.combineLatest(textSubject, otpLengthSubject).map { $0.0?.count ?? 0 == $0.1 }.bind(to: validSubject).disposed(by: disposeBag)
        
        generateOneTimePasscode(mobileNo: mobileNo)
        verifyOneTimePasscode(mobileNo: mobileNo)
        
        Observable.combineLatest(otpBlocked, timerSubject.map{ $0 <= 0})
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
                //return self.repository.generateLoginOTP(username: mobileNo, passcode: "1212", deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "")
                return self.repository.generateOTP(action: otpAction!, mobileNumber: mobileNo)
            }
            .do(onNext: {_ in
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
        
        generateOTPRequest.elements().skip(1).map { _ in "New OTP has been generated successfully" }.bind(to: showAlertSubject).disposed(by: disposeBag)
    }
    
    open func verifyOneTimePasscode(mobileNo: String) {
        
        let verifyRequest = sendSubject
            .withLatestFrom(Observable.combineLatest(textSubject.unwrap(), otpActionSubject))
            .do(onNext: {[unowned self] _ in
                self.editingSubject.onNext(false)
                YAPProgressHud.showProgressHud()
            })
            .flatMap { [unowned self] text, action -> Observable<Event<String?>> in
                ///self.repository.verifyOTP(text, action: action!, mobileNumber: mobileNo)
                return self.repository.generateLoginOTP(username: mobileNo, passcode: "1212", deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "")
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

}

public extension VerifyMobileOTPViewModel {
    
    func startTimer() -> Disposable {
        let timer = Observable<NSInteger>.timer(RxTimeInterval.milliseconds(0), period: RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        return Observable.combineLatest(timer, resendTimeSubject)
            .map { $0.1 - TimeInterval($0.0) }
            .bind(to: timerSubject)
    }
}

// TODO: globalize extension to TimeInterval
fileprivate extension VerifyMobileOTPViewModel {
    
    func timeString(timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval/60.0)
        let seconds = Int(timeInterval) % 60
        
        return String.init(format: "%02d:%02d", minutes, seconds)
    }
    
}
