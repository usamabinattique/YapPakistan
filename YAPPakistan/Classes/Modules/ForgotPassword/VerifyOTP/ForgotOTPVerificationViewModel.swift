//
//  ForgotOTPVerificationViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 28/09/2021.
//

import Foundation
import RxSwift
import YAPComponents

class ForgotOTPVerificationViewModel: VerifyMobileOTPViewModel {
    private let username: String
    private let passcode: String
    var timerDisposable: Disposable?

    init(action: OTPAction,
         heading: String? = nil,
         subheading: String,
         image: UIImage? = nil,
         badge: UIImage? = nil,
         otpTime: TimeInterval = 10,
         otpLength: Int = 6,
         resendTries: Int = 4,
         repository: OTPRepositoryType,
         mobileNo: String = "",
         backButtonImage: BackButtonType = .backEmpty,
         username: String,
         passcode: String,
         sessionCreator: SessionProviderType) {

        self.username = username
        self.passcode = passcode

        super.init(action: action, heading: heading, subheading: subheading, image: image,
                   badge: badge, otpTime: otpTime, otpLength: otpLength, resendTries: resendTries,
                   repository: repository, mobileNo: mobileNo, passcode: passcode, backButtonImage: backButtonImage)

        viewAppearedSubject.filter{ $0 }.bind(to: editingSubject).disposed(by: disposeBag)
        timerDisposable = startTimer()
    }

    override func generateOneTimePasscode(mobileNo: String) {
        let generateOTPRequest = generateOTPSubject
            .do(onNext: { YAPProgressHud.showProgressHud() })
            .flatMap { [unowned self] _ -> Observable<Event<String?>> in
                return self.repository.generateForgotOTP(username: mobileNo)
            }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()

        generateOTPRequest.errors()
            .map { $0.localizedDescription }
            .bind(to: generateOTPErrorSubject)
            .disposed(by: disposeBag)

        generateOTPRequest.elements().do(onNext: { [unowned self] _ in
            self.timerDisposable?.dispose()
            self.timerDisposable = self.startTimer()
        }).map { _ in true }.bind(to: editingSubject).disposed(by: disposeBag)

        generateOTPRequest.skip(1).elements().map { _ in "screen_otp_genration_success".localized }
            .bind(to: showAlertSubject).disposed(by: disposeBag)
    }

    override func verifyOneTimePasscode(mobileNo: String, passcode: String) {

        let verifyRequest = sendSubject.withLatestFrom(textSubject.unwrap())
            .do(onNext: { [unowned self] _ in
                self.editingSubject.onNext(false)
                YAPProgressHud.showProgressHud()
            })
            .flatMap { [unowned self] otp -> Observable<Event<String?>> in
                self.repository.verifyForgotOTP(username: mobileNo, otp: otp)
            }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()

        verifyRequest.errors().map{ error -> Bool in
            guard case let NetworkErrors.internalServerError(serverError) = error else { return false }
            guard serverError?.errors.first?.code == "1095" else { return false }
            return true
        }
        .bind(to: otpBlocked)
        .disposed(by: disposeBag)

        verifyRequest.errors().map { $0.localizedDescription }.bind(to: errorSuject).disposed(by: disposeBag)
        verifyRequest.errors().map { _ in nil }
            .do(onNext: { [unowned self] in self.otpForRequest = $0 })
            .bind(to: textSubject).disposed(by: disposeBag)

        verifyRequest.elements().unwrap().bind(to: OTPResultSubject).disposed(by: disposeBag)
    }
}

