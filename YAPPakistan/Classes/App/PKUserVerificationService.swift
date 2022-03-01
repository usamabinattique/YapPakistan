//
//  YapPkManager.swift
//  YAPSuperApp
//
//  Created by Zara on 20/02/2022.
//

import Foundation
import RxSwift
import YAPCore

public protocol UserVerificationType {
    func verifySignInUser(username: String, _ observer: AnyObserver<(Bool, Error?)>)
    func verifySignUpUser(countryCode: String, username: String, _ observer: AnyObserver<(Bool, Error?)>)
}


final class PKUserVerificationService: UserVerificationType {
    
    private var loginRepository: LoginRepositoryType?
    private var onBoardRepository: OnBoardingRepositoryType?
    private let disposeBag = DisposeBag()
    
    init(loginRepository: LoginRepository? = nil , onBoardRepository: OnBoardingRepositoryType? = nil) {
        self.loginRepository = loginRepository
        self.onBoardRepository = onBoardRepository
    }
    
    // need to verify user
    public func verifySignInUser(username: String, _ observer: AnyObserver<(Bool, Error?)>) {
        
        let userRequest = loginRepository?.verifyUser(username: username).share()
        
        userRequest?.elements().filter { $0 == false }.subscribe(onNext: { _ in
            observer.onNext((false, nil))
        }).disposed(by: disposeBag)
        
        userRequest?.elements().filter { $0 == true }.subscribe(onNext: { _ in
            observer.onNext((true, nil))
        }).disposed(by: disposeBag)
        
        userRequest?.errors().subscribe(onNext: { error in
            observer.onNext((false, error))
        }).disposed(by: disposeBag)
    }
    
    // need for onboard process
    public func verifySignUpUser(countryCode: String, username: String, _ observer: AnyObserver<(Bool, Error?)>) {
        // call generateOTP API
        
        let otpRequest = onBoardRepository?.signUpOTP(countryCode: countryCode, mobileNo: username, accountType: AccountType.b2cAccount.rawValue).share()
        
        otpRequest?.elements().subscribe(onNext: { _ in
            observer.onNext((true, nil))
        }).disposed(by: disposeBag)
        
        otpRequest?.errors().subscribe(onNext: { error in
            observer.onNext((false, error))
        }).disposed(by: disposeBag)
    }
    
    deinit { 
        debugPrint("Bye: YAPPK PKUserVerificationService")
    }
}
