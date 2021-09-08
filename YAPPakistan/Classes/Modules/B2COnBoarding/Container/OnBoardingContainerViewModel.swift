//
//  OnBoardingContainerViewModel.swift
//  YAP
//
//  Created by Zain on 21/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

enum OnboardingStage {
    case none
    case phone
    case otp
    case name
    case passcode
    case email
    case emailVerify
    case companyName
}

protocol OnBoardingContainerViewModelInput {
    var sendObserver: AnyObserver<OnboardingStage> { get }
    var validObserver: AnyObserver<Bool> { get }
    var activeStageObserver: AnyObserver<OnboardingStage> { get }
}

protocol OnBoardingContainerViewModelOutput {
    var send: Observable<OnboardingStage> { get }
    var valid: Observable<Bool> { get }
    var activeStage: Observable<OnboardingStage> { get }
}

protocol OnBoardingContainerViewModelType {
    var inputs: OnBoardingContainerViewModelInput { get }
    var outputs: OnBoardingContainerViewModelOutput { get }
}

class OnBoardingContainerViewModel: OnBoardingContainerViewModelInput, OnBoardingContainerViewModelOutput, OnBoardingContainerViewModelType {
    
    var inputs: OnBoardingContainerViewModelInput { return self }
    var outputs: OnBoardingContainerViewModelOutput { return self }
    
    private let sendSubject = PublishSubject<OnboardingStage>()
    private let validSubject = PublishSubject<Bool>()
    private let activeStageSubject = BehaviorSubject<OnboardingStage>(value: .none)
    
    //inputs
    var sendObserver: AnyObserver<OnboardingStage> { return sendSubject.asObserver() }
    var validObserver: AnyObserver<Bool> { return validSubject.asObserver() }
    var activeStageObserver: AnyObserver<OnboardingStage> { return activeStageSubject.asObserver() }
    
    //outputs
    var send: Observable<OnboardingStage> { return sendSubject.asObservable() }
    var valid: Observable<Bool> { return validSubject.asObservable() }
    var activeStage: Observable<OnboardingStage> { return activeStageSubject.asObservable() }
}
