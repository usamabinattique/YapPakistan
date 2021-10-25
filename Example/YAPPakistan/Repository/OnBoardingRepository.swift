//
//  OnBoardingRepository.swift
//  YAPPakistan_Example
//
//  Created by Umer on 05/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import YAPPakistan

protocol OnBoardingRepositoryType {
    func signUpOTP(countryCode: String, mobileNo: String, accountType: String) -> Observable<Event<String?>>
}

extension YAPPakistan.OnBoardingRepository: OnBoardingRepositoryType {
    func signUpOTP(countryCode: String, mobileNo: String, accountType: String) -> Observable<Event<String?>> {
        messagesService.signUpOTP(countryCode: countryCode, mobileNo: mobileNo, accountType: accountType).materialize()
    }
}
