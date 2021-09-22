//
//  LoginOTPVerificationViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 20/09/2021.
//

import Foundation
import RxSwift
import YAPComponents

class LoginOTPVerificationViewModel: VerifyMobileOTPViewModel {
    
    private let username: String
    private let passcode: String
    private let sessionCreator: SessionProviderType
    var timerDisposable: Disposable?

    private let onLoginClosure: OnLoginClosure

    private var session: Session!
    private var accountProvider: AccountProvider?

    private let saveDeviceSubject = PublishSubject<Void>()
    private var demographicsRepository: DemographicsRepositoryType!

    init(action: OTPAction, heading: NSAttributedString? = nil,
         subheading: NSAttributedString,
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
         sessionCreator: SessionProviderType,
         onLogin: @escaping OnLoginClosure) {
        
        self.username = username
        self.passcode = passcode
        self.sessionCreator = sessionCreator
        self.onLoginClosure = onLogin
        
        super.init(action: action, heading: heading, subheading: subheading, image: image,
                   badge: badge, otpTime: otpTime, otpLength: otpLength, resendTries: resendTries,
                   repository: repository, mobileNo: mobileNo, backButtonImage: backButtonImage)
        
        viewAppearedSubject.filter{ $0 }.bind(to: editingSubject).disposed(by: disposeBag)
        timerDisposable = startTimer()
        
        
        //YAPProgressHud.showProgressHud()
        //repository
        //    .generateLoginOTP(username: username, passcode: passcode, deviceId: UIDevice.deviceID)
        //    .debug()
        //    .subscribe( onNext: { _ in YAPProgressHud.hideProgressHud() })
        //    .disposed(by: disposeBag)
    }

    override func generateOneTimePasscode(mobileNo: String) {
        let generateOTPRequest = generateOTPSubject
            .do(onNext: { YAPProgressHud.showProgressHud() })
            .flatMap { [unowned self] _ -> Observable<Event<String?>> in
                return self.repository.generateLoginOTP(username: self.username, passcode: self.passcode, deviceId: UIDevice.deviceID) }
            .do(onNext: {_ in YAPProgressHud.hideProgressHud() })
            .share()
        
        generateOTPRequest.errors()
            .map { $0.localizedDescription }
            .bind(to: generateOTPErrorSubject)
            .disposed(by: disposeBag)

        generateOTPRequest.elements().do(onNext: { [unowned self] _ in
            self.timerDisposable?.dispose()
            self.timerDisposable = self.startTimer()
        }).map { _ in true }.bind(to: editingSubject).disposed(by: disposeBag)
        
        generateOTPRequest.skip(1).elements().map { _ in "New OTP has been generated successfully" }.bind(to: showAlertSubject).disposed(by: disposeBag)
    }
    
    override func verifyOneTimePasscode(mobileNo: String) {
        
        let verifyRequest = sendSubject.withLatestFrom(textSubject.unwrap())
            .do(onNext: {[unowned self] _ in
                self.editingSubject.onNext(false)
                YAPProgressHud.showProgressHud()
            })
            .flatMap { [unowned self] text -> Observable<Event<String?>> in
                self.repository.verifyLoginOTP(username: self.username, passcode: self.passcode, deviceId: UIDevice.deviceID, otp: text)
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
        
        verifyRequest.elements().subscribe(onNext: { data in
            guard let componenets = data?.components(separatedBy: "%") else { return }
            let token = componenets.first

            if let jwt = componenets.count > 1 ? componenets.last : nil {
                self.session = self.sessionCreator.makeUserSession(jwt: jwt)
            }

            self.onLoginClosure(self.session, &self.accountProvider, &self.demographicsRepository)
            self.saveDeviceSubject.onNext(())
            self.refreshAccount()
        }).disposed(by: disposeBag)

        saveDeviceSubject.flatMap { _ in
            return self.demographicsRepository.saveDemographics(action: "LOGIN", token: nil)
        }.subscribe().disposed(by: disposeBag)
    }

    private func refreshAccount() {
        guard let accountProvider = accountProvider else {
            return assertionFailure()
        }

        accountProvider.refreshAccount()
        accountProvider.currentAccount
            .unwrap()
            .do(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            })
            .subscribe(onNext: { account in
                if account.isWaiting {
                    self.loginResultSubject.onNext(.waiting)
                } else if (account.iban ?? "").isEmpty {
                    self.loginResultSubject.onNext(.allowed)
                } else if account.isOTPBlocked {
                    self.loginResultSubject.onNext(.blocked)
                } else {
                    self.loginResultSubject.onNext(.dashboard)
                }
            })
            .disposed(by: disposeBag)
    }
}
